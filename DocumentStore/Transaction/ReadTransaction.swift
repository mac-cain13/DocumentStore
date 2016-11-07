//
//  ReadTransaction.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 04-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation
import CoreData

public class ReadTransaction {
  private let context: NSManagedObjectContext
  private let documentDescriptors: [AnyDocumentDescriptor]
  private let logger: Logger

  init(context: NSManagedObjectContext, documentDescriptors: [AnyDocumentDescriptor], logTo logger: Logger) {
    self.context = context
    self.documentDescriptors = documentDescriptors
    self.logger = logger
  }

  func validateUseOfDocumentType<DocumentType: Document>(_: DocumentType.Type) throws {
    guard documentDescriptors.contains(DocumentType.documentDescriptor.eraseType()) else {
      let error = DocumentStoreError(
        kind: .documentDescriptionNotRegistered,
        message: "The document description with identifier '\(DocumentType.documentDescriptor.identifier)' is not registered with the DocumentStore this transaction is associated with, please pass all DocumentDescriptions that are used to the DocumentStore initializer.",
        underlyingError: nil
      )
      throw TransactionError.DocumentStoreError(error)
    }
  }

  func count<DocumentType>(matching query: Query<DocumentType>) throws -> Int {
    try validateUseOfDocumentType(DocumentType.self)

    let request: NSFetchRequest<NSNumber> = query.fetchRequest()

    do {
      return try context.count(for: request)
    } catch let underlyingError {
      let error = DocumentStoreError(
        kind: .fetchRequestFailed,
        message: "Failed to count '\(DocumentType.documentDescriptor.identifier)' documents. This is an error in the DocumentStore library, please report this issue.",
        underlyingError: underlyingError
      )
      logger.log(level: .error, message: "Error while performing count.", error: error)
      throw TransactionError.DocumentStoreError(error)
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
      fetchResult = try context.fetch(request)
    } catch let underlyingError {
      let error = DocumentStoreError(
        kind: .fetchRequestFailed,
        message: "Failed to fetch '\(DocumentType.documentDescriptor.identifier)' documents. This is an error in the DocumentStore library, please report this issue.",
        underlyingError: underlyingError
      )
      logger.log(level: .error, message: "Error while performing fetch.", error: error)
      throw TransactionError.DocumentStoreError(error)
    }

    // Deserialize documents
    return try fetchResult
      .flatMap {
        do {
          guard let documentData = $0.value(forKey: DocumentDataAttributeName) as? Data else {
            let error = DocumentStoreError(
              kind: .documentDataAttributeCorruption,
              message: "Failed to retrieve '\(DocumentDataAttributeName)' attribute contents and cast it to `Data` for a '\(DocumentType.documentDescriptor.identifier)' document. This is an error in the DocumentStore library, please report this issue.",
              underlyingError: nil
            )
            logger.log(level: .error, message: "Encountered corrupt '\(DocumentDataAttributeName)' attribute.", error: error)
            throw DocumentDeserializationError(resolution: .Skip, underlyingError: error)
          }

          return try DocumentType.deserializeDocument(from: documentData)
        } catch let error as DocumentDeserializationError {
          logger.log(level: .warn, message: "Deserializing '\(DocumentType.documentDescriptor.identifier)' document failed, recovering with '\(error.resolution)' resolution.", error: error.underlyingError)

          switch error.resolution {
          case .Delete:
            context.delete($0)
          case .Skip:
            break
          }

          return nil
        } catch let error {
          throw TransactionError.SerializationFailed(error)
        }
      }
  }
}
