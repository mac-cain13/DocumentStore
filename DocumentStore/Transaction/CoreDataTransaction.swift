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
  private let documentDescriptors: ValidatedDocumentDescriptors
  private let logger: Logger

  init(context: NSManagedObjectContext, documentDescriptors: ValidatedDocumentDescriptors, logTo logger: Logger) {
    self.context = context
    self.documentDescriptors = documentDescriptors
    self.logger = logger
  }

  private func validateUseOfDocumentType<DocumentType: Document>(_: DocumentType.Type) throws {
    guard documentDescriptors.documentDescriptors.contains(DocumentType.documentDescriptor.eraseType()) else {
      let error = DocumentStoreError(
        kind: .documentDescriptionNotRegistered,
        message: "The document description with identifier '\(DocumentType.documentDescriptor.identifier)' is not registered with the DocumentStore this transaction is associated with, please pass all DocumentDescriptions that are used to the DocumentStore initializer.",
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
        message: "Failed to count '\(DocumentType.documentDescriptor.identifier)' documents. This is an error in the DocumentStore library, please report this issue.",
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
        message: "Failed to fetch '\(DocumentType.documentDescriptor.identifier)' documents. This is an error in the DocumentStore library, please report this issue.",
        underlyingError: underlyingError
      )
      logger.log(level: .error, message: "Error while performing fetch.", error: error)
      throw TransactionError.documentStoreError(error)
    }

    // Deserialize documents
    return try fetchResult
      .flatMap {
        do {
          guard let documentData = $0.value(forKey: DocumentDataAttributeName) as? Data else {
            let error = DocumentStoreError(
              kind: .documentDataCorruption,
              message: "Failed to retrieve '\(DocumentDataAttributeName)' attribute contents and cast it to `Data` for a '\(DocumentType.documentDescriptor.identifier)' document. This is an error in the DocumentStore library, please report this issue.",
              underlyingError: nil
            )
            logger.log(level: .error, message: "Encountered corrupt '\(DocumentDataAttributeName)' attribute.", error: error)
            throw DocumentDeserializationError(resolution: .skipDocument, underlyingError: error)
          }

          return try DocumentType.deserializeDocument(from: documentData)
        } catch let error as DocumentDeserializationError {
          logger.log(level: .warn, message: "Deserializing '\(DocumentType.documentDescriptor.identifier)' document failed, recovering with '\(error.resolution)' resolution.", error: error.underlyingError)

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
        message: "Failed to fetch '\(DocumentType.documentDescriptor.identifier)' documents. This is an error in the DocumentStore library, please report this issue.",
        underlyingError: underlyingError
      )
      logger.log(level: .error, message: "Error while performing fetch.", error: error)
      throw TransactionError.documentStoreError(error)
    }
  }

  func add<DocumentType: Document>(document: DocumentType) throws {
    try validateUseOfDocumentType(DocumentType.self)

    do {
      let documentData = try document.serializeDocument()

      try convertExceptionToError {
        let entity = NSEntityDescription.insertNewObject(forEntityName: DocumentType.documentDescriptor.identifier, into: context)
        entity.setValue(documentData, forKey: DocumentDataAttributeName)
        DocumentType.documentDescriptor.indices.forEach {
          entity.setValue($0.resolver(document), forKey: $0.identifier)
        }
      }
    } catch let error {
      throw TransactionError.serializationFailed(error)
    }
  }

  func saveChanges() throws {
    if context.hasChanges {
      try context.save()
    }
  }

}
