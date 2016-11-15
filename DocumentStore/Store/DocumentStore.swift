//
//  Store.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 03-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation
import CoreData

/// The store where `Document`s are stored and can retrieved using `Collection`s in transactions.
public final class DocumentStore {
  private let persistentContainer: NSPersistentContainer
  private let documentDescriptors: [AnyDocumentDescriptor]
  private let logger: Logger

  /// Create a `DocumentStore`.
  ///
  /// - Note: The identifier is basically the filename of the `DocumentStore` changing the 
  ///         identifier will result in the creation of a new empty store.
  ///
  /// - Parameters:
  ///   - identifier: The unique unchangable identifier of this `DocumentStore`
  ///   - documentDescriptors: All `DocumentDescriptor`s of `Document`s that will be used at any point in time
  ///   - logger: Optional logger to use
  /// - Throws: `DocumentStoreError`s if initializations fails due invalid `DocumentDescriptor`s
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

  /// Perform a read transaction on the store and get the result back in a handler.
  ///
  /// - Warning: Do not use the `ReadTransaction` outside of the actions block, this will result in 
  ///            undefined behaviour.
  ///
  /// - Note: Actions block will be executed on a arbitrary background thread managed by the store.
  ///
  /// - Parameters:
  ///   - queue: Queue to perform the handler on
  ///   - handler: Handler that will be called with the result of the transaction
  ///   - actions: Actions to perform in this transaction, returned result is passed to the handler
  public func read<T>(queue: DispatchQueue = DispatchQueue.main, handler: @escaping (TransactionResult<T>) -> Void, actions: @escaping (ReadTransaction) throws -> T) {
    readWrite(queue: queue, handler: handler) { transaction in
      let result = try actions(transaction)
      return (.discardChanges, result)
    }
  }

  /// Perform a write transaction on the store and get the result back in a handler.
  ///
  /// - Warning: Do not use the `ReadWriteTransaction` outside of the actions block, this will
  ///            result in undefined behaviour.
  ///
  /// - Note: Actions block will be executed on a arbitrary background thread managed by the store.
  ///
  /// - Parameters:
  ///   - queue: Queue to perform the handler on
  ///   - handler: Handler that will be called with the result of the transaction
  ///   - actions: Actions to perform in this transaction, returned commit action will be executed
  public func write(queue: DispatchQueue = DispatchQueue.main, handler: @escaping (TransactionResult<Void>) -> Void, actions: @escaping (ReadWriteTransaction) throws -> CommitAction) {
    readWrite(queue: queue, handler: handler) { transaction in
      let commitAction = try actions(transaction)
      return (commitAction, ())
    }
  }

  /// Perform a read/write transaction on the store and get the result back in a handler.
  ///
  /// - Warning: Do not use the `ReadWriteTransaction` outside of the actions block, this will
  ///            result in undefined behaviour.
  ///
  /// - Note: Actions block will be executed on a arbitrary background thread managed by the store.
  ///
  /// - Parameters:
  ///   - queue: Queue to perform the handler on
  ///   - handler: Handler that will be called with the result of the transaction
  ///   - actions: Actions to perform in this transaction, returned result is passed to the handler, commit action will be executed
  public func readWrite<T>(queue: DispatchQueue = DispatchQueue.main, handler: @escaping (TransactionResult<T>) -> Void, actions: @escaping (ReadWriteTransaction) throws -> (CommitAction, T)) {
    persistentContainer.performBackgroundTask { [logger, documentDescriptors] context in
      context.mergePolicy = NSMergePolicy.overwrite

      do {
        try context.setQueryGenerationFrom(NSQueryGenerationToken.current)
      } catch let error {
        logger.log(level: .warn, message: "Failed to pin transaction, this could lead to inconsistent read operations.", error: error)
      }

      let coreDataTransaction = CoreDataTransaction(context: context, documentDescriptors: documentDescriptors, logTo: logger)
      let transaction = ReadWriteTransaction(transaction: coreDataTransaction)
      do {
        let (commitAction, result) = try actions(transaction)

        if case .saveChanges = commitAction {
          do {
            try transaction.saveChanges()
          } catch let error {
            let documentStoreError = DocumentStoreError(kind: .operationFailed, message: "Failed to save changes from a transaction to the store.", underlyingError: error)
            return queue.async { handler(.failure(.documentStoreError(documentStoreError))) }
          }
        }

        return queue.async { handler(.success(result)) }
      } catch let error {
        return queue.async { handler(.failure(.actionThrewError(error))) }
      }
    }
  }
}