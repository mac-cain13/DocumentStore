//
//  Transaction.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 04-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation
import CoreData

public enum TransactionResult<T> {
  case Success(T)
  case Failure(TransactionError)
}

public enum TransactionError: Error {
  case ActionThrewError(Error)
  case SaveFailed(Error)
  case SerializationFailed(Error)
  case DocumentStoreError(DocumentStoreError)
}

public enum CommitAction {
  case SaveChanges
  case DiscardChanges
}

public class ReadTransaction {
  fileprivate let context: NSManagedObjectContext
  fileprivate let logger: Logger

  init(context: NSManagedObjectContext, logger: Logger) {
    self.context = context
    self.logger = logger
  }

  func count<DocumentType>(matching query: Query<DocumentType>) throws -> Int {
    let request: NSFetchRequest<NSNumber> = fetchRequest(for: query)

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
    // Set up the fetch request
    let request: NSFetchRequest<NSManagedObject> = fetchRequest(for: query)
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

public final class ReadWriteTransaction: ReadTransaction {
  @discardableResult
  public func delete<DocumentType>(matching query: Query<DocumentType>) throws -> Int {
    let request: NSFetchRequest<NSManagedObject> = fetchRequest(for: query)
    request.includesPropertyValues = false

    do {
      let fetchResult = try context.fetch(request)
      fetchResult.forEach(context.delete)
      return fetchResult.count
    } catch let underlyingError {
      let error = DocumentStoreError(
        kind: .fetchRequestFailed,
        message: "Failed to fetch '\(DocumentType.documentDescriptor.identifier)' documents. This is an error in the DocumentStore library, please report this issue.",
        underlyingError: underlyingError
      )
      logger.log(level: .error, message: "Error while performing fetch.", error: error)
      throw TransactionError.DocumentStoreError(error)
    }
  }

  public func add<DocumentType: Document>(document: DocumentType) throws {
    let entity = NSEntityDescription.insertNewObject(forEntityName: DocumentType.documentDescriptor.identifier, into: context)

    do {
      let documentData = try document.serializeDocument()
      entity.setValue(documentData, forKey: DocumentDataAttributeName)
    } catch let error {
      throw TransactionError.SerializationFailed(error)
    }

    DocumentType.documentDescriptor.indices.forEach {
      entity.setValue($0.resolver(document), forKey: $0.identifier)
    }
  }

  func saveChanges() throws {
    if context.hasChanges {
      try context.save()
    }
  }
}

private func fetchRequest<DocumentType, ResultType>(for query: Query<DocumentType>) -> NSFetchRequest<ResultType> {
  let request = NSFetchRequest<ResultType>(entityName: DocumentType.documentDescriptor.identifier)
  request.predicate = query.predicate
  request.sortDescriptors = query.sortDescriptors
  request.fetchOffset = query.skip
  if let limit = query.limit {
    request.fetchLimit = limit
  }

  switch ResultType.self {
  case is NSManagedObject.Type:
    request.resultType = .managedObjectResultType
  case is NSManagedObjectID.Type:
    request.resultType = .managedObjectIDResultType
  case is NSDictionary.Type:
    request.resultType = .dictionaryResultType
  case is NSNumber.Type:
    request.resultType = .countResultType
  default:
    assertionFailure("This type of NSFetchRequestResult is not supported by DocumentStore.Transaction.")
  }

  return request
}
