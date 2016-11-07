//
//  Store.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 03-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation
import CoreData

public struct DocumentStoreError: Error, CustomStringConvertible {
  public enum ErrorKind: Int {
    case documentDescriptionInvalid = 1
    case documentDescriptionNotRegistered
    case fetchRequestFailed
    case documentDataAttributeCorruption
  }

  public let kind: ErrorKind
  public let message: String
  public let underlyingError: Error?

  public var description: String {
    let underlyingErrorDescription = underlyingError.map { " - \($0)" } ?? ""
    return "DocumentStoreError #\(kind.rawValue): \(message)\(underlyingErrorDescription)"
  }
}

public final class DocumentStore {
  private let persistentContainer: NSPersistentContainer
  private let documentDescriptors: [AnyDocumentDescriptor]
  private let logger: Logger

  public init(identifier: String, documentDescriptors: [AnyDocumentDescriptor], logTo logger: Logger = NoLogger()) throws {
    self.documentDescriptors = documentDescriptors
    self.logger = logger

    // Validate document descriptors
    logger.log(level: .debug, message: "Validating document descriptors...")
    try validate(documentDescriptors, logTo: logger)

    // Generate data model
    logger.log(level: .debug, message: "Generating data model...")
    let model = managedObjectModel(from: documentDescriptors, logTo: logger)

    // Setup persistent stack
    logger.log(level: .debug, message: "Setting up persistent store...")

    persistentContainer = NSPersistentContainer(name: identifier, managedObjectModel: model)
    persistentContainer.loadPersistentStores { _, error in
      if let error = error {
        logger.log(level: .error, message: "Failed to load persistent store, this will result in an unusable DocumentStore.", error: error)
      }
    }
  }

  // MARK: Transaction initialization

  public func read<T>(queue: DispatchQueue = DispatchQueue.main, handler: @escaping (TransactionResult<T>) -> Void, actions: @escaping (ReadTransaction) throws -> T) {
    readWrite(queue: queue, handler: handler) { transaction in
      let result = try actions(transaction)
      return (.DiscardChanges, result)
    }
  }

  public func write(queue: DispatchQueue = DispatchQueue.main, handler: @escaping (TransactionResult<Void>) -> Void, actions: @escaping (ReadWriteTransaction) throws -> CommitAction) {
    readWrite(queue: queue, handler: handler) { transaction in
      let commitAction = try actions(transaction)
      return (commitAction, ())
    }
  }

  public func readWrite<T>(queue: DispatchQueue = DispatchQueue.main, handler: @escaping (TransactionResult<T>) -> Void, actions: @escaping (ReadWriteTransaction) throws -> (CommitAction, T)) {
    persistentContainer.performBackgroundTask { [logger, documentDescriptors] context in
      context.mergePolicy = NSMergePolicy.overwrite

      do {
        try context.setQueryGenerationFrom(NSQueryGenerationToken.current)
      } catch let error {
        logger.log(level: .warn, message: "Failed to pin transaction, this could lead to inconsistent read operations.", error: error)
      }

      let transaction = ReadWriteTransaction(context: context, documentDescriptors: documentDescriptors, logTo: logger)
      do {
        let (commitAction, result) = try actions(transaction)

        if case .SaveChanges = commitAction {
          do {
            try transaction.saveChanges()
          } catch let error {
            return queue.async { handler(.Failure(.SaveFailed(error))) }
          }
        }

        return queue.async { handler(.Success(result)) }
      } catch let error {
        return queue.async { handler(.Failure(.ActionThrewError(error))) }
      }
    }
  }
}
