//
//  CoreDataTransaction.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 12-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation
import CoreData

class CoreDataTransaction: ReadWritableTransaction {
  private let context: NSManagedObjectContext
  private let validatedDocumentDescriptors: ValidatedDocumentDescriptors
  private let logger: Logger

  init(context: NSManagedObjectContext, documentDescriptors: ValidatedDocumentDescriptors, logTo logger: Logger) {
    self.context = context
    self.validatedDocumentDescriptors = documentDescriptors
    self.logger = logger
  }

  private func validateUseOfDocumentType<DocumentType: Document>(_: DocumentType.Type) throws {
    guard validatedDocumentDescriptors.documentDescriptors.contains(DocumentType.documentDescriptor) else {
      let error = DocumentStoreError(
        kind: .documentDescriptionNotRegistered,
        message: "The document description with identifier '\(DocumentType.documentDescriptor.name)' is not registered with the DocumentStore this transaction is associated with, please pass all DocumentDescriptions that are used to the DocumentStore initializer.",
        underlyingError: nil
      )
      throw TransactionError.documentStoreError(error)
    }
  }

  func count<DocumentType>(matching query: Query<DocumentType>) throws -> Int {
    try validateUseOfDocumentType(DocumentType.self)

    let request: NSFetchRequest<NSNumber> = query.fetchRequest()

    do {
      return try convertExceptionToError {
        try context.count(for: request)
      }
    } catch let underlyingError {
      let error = DocumentStoreError(
        kind: .operationFailed,
        message: "Failed to count '\(DocumentType.documentDescriptor.name)' documents. This is an error in the DocumentStore library, please report this issue.",
        underlyingError: underlyingError
      )
      logger.log(level: .error, message: "Error while performing count.", error: error)
      throw TransactionError.documentStoreError(error)
    }
  }

  func fetch<DocumentType>(matching query: Query<DocumentType>) throws -> [DocumentType] {
    try validateUseOfDocumentType(DocumentType.self)

    // Set up the fetch request
    let request: NSFetchRequest<NSManagedObject> = query.fetchRequest()
    request.returnsObjectsAsFaults = false

    // Perform the fetch
    let fetchResult: [NSManagedObject]
    do {
      fetchResult = try convertExceptionToError {
        try context.fetch(request)
      }
    } catch let underlyingError {
      let error = DocumentStoreError(
        kind: .operationFailed,
        message: "Failed to fetch '\(DocumentType.documentDescriptor.name)' documents. This is an error in the DocumentStore library, please report this issue.",
        underlyingError: underlyingError
      )
      logger.log(level: .error, message: "Error while performing fetch.", error: error)
      throw TransactionError.documentStoreError(error)
    }

    // Deserialize documents
    return try fetchResult
      .compactMap {
        do {
          guard let documentData = $0.value(forKey: DocumentDataAttributeName) as? Data else {
            let error = DocumentStoreError(
              kind: .documentDataCorruption,
              message: "Failed to retrieve '\(DocumentDataAttributeName)' attribute contents and cast it to `Data` for a '\(DocumentType.documentDescriptor.name)' document. This is an error in the DocumentStore library, please report this issue.",
              underlyingError: nil
            )
            logger.log(level: .error, message: "Encountered corrupt '\(DocumentDataAttributeName)' attribute.", error: error)
            throw DocumentDeserializationError(resolution: .skipDocument, underlyingError: error)
          }

          return try DocumentType.decode(from: documentData)
        } catch let error as DocumentDeserializationError {
          logger.log(level: .warn, message: "Deserializing '\(DocumentType.documentDescriptor.name)' document failed, recovering with '\(error.resolution)' resolution.", error: error.underlyingError)

          switch error.resolution {
          case .deleteDocument:
            context.delete($0)
            return nil
          case .skipDocument:
            return nil
          case .abortOperation:
            throw TransactionError.serializationFailed(error.underlyingError)
          }
        } catch let error {
          throw TransactionError.serializationFailed(error)
        }
    }
  }

  func insert<DocumentType: Document>(document: DocumentType, mode: InsertMode) throws -> Bool {
    try validateUseOfDocumentType(DocumentType.self)

    let identifierValue = DocumentType.documentDescriptor.identifier.resolver(document)
    let currentManagedObject = try fetchManagedObject(for: document, with: identifierValue)

    let managedObject: NSManagedObject
    switch (mode, currentManagedObject) {
    case (.replaceOnly, .none), (.addOnly, .some):
      return false
    case (.replaceOnly, let .some(currentManagedObject)), (.addOrReplace, let .some(currentManagedObject)):
      managedObject = currentManagedObject
    case (.addOnly, .none), (.addOrReplace, .none):
      managedObject = NSEntityDescription.insertNewObject(forEntityName: DocumentType.documentDescriptor.name, into: context)
    }

    do {
      let documentData = try DocumentType.encode(document)

      try convertExceptionToError {
        managedObject.setValue(documentData, forKey: DocumentDataAttributeName)
        managedObject.setValue(identifierValue, forKey: DocumentType.documentDescriptor.identifier.storageInformation.propertyName.keyPath)
        DocumentType.documentDescriptor.indices.forEach {
          managedObject.setValue($0.resolver(document), forKey: $0.storageInformation.propertyName.keyPath)
        }
      }

      return true
    } catch let error {
      throw TransactionError.serializationFailed(error)
    }
  }

  @discardableResult
  func delete<DocumentType>(matching query: Query<DocumentType>) throws -> Int {
    try validateUseOfDocumentType(DocumentType.self)

    let request: NSFetchRequest<NSManagedObject> = query.fetchRequest()
    request.includesPropertyValues = false

    do {
      let fetchResult = try convertExceptionToError { try context.fetch(request) }
      fetchResult.forEach(context.delete)
      return fetchResult.count
    } catch let underlyingError {
      let error = DocumentStoreError(
        kind: .operationFailed,
        message: "Failed to fetch '\(DocumentType.documentDescriptor.name)' documents. This is an error in the DocumentStore library, please report this issue.",
        underlyingError: underlyingError
      )
      logger.log(level: .error, message: "Error while performing fetch.", error: error)
      throw TransactionError.documentStoreError(error)
    }
  }

  @discardableResult
  func delete<DocumentType: Document>(document: DocumentType) throws -> Bool {
    try validateUseOfDocumentType(DocumentType.self)

    guard let managedObject = try fetchManagedObject(for: document) else {
      return false
    }

    context.delete(managedObject)
    return true
  }

  func persistChanges() throws {
    if context.hasChanges {
      try context.save()
    }
  }

  private func fetchManagedObject<DocumentType: Document>(for document: DocumentType, with identifierValue: Any? = nil) throws -> NSManagedObject? {
    let identifierValue = identifierValue ?? DocumentType.documentDescriptor.identifier.resolver(document)

    let request = NSFetchRequest<NSManagedObject>(entityName: DocumentType.documentDescriptor.name)
    request.predicate = NSComparisonPredicate(
      leftExpression: NSExpression(forKeyPath: DocumentType.documentDescriptor.identifier.storageInformation.propertyName.keyPath),
      rightExpression: NSExpression(forConstantValue: identifierValue),
      modifier: .direct,
      type: .equalTo
    )
    request.resultType = .managedObjectResultType

    return try convertExceptionToError {
      try context.fetch(request).first
    }
  }
}
