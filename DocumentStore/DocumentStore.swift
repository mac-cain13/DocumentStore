//
//  Store.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 03-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation
import CoreData

let DocumentDataAttributeName = "_DocumentData"

/// DocumentStore
public final class DocumentStore {
  private let persistentContainer: NSPersistentContainer
  private let logger: Logger

  public init(identifier: String, documentDescriptors: [AnyDocumentDescriptor], logger: Logger = NoLogger()) throws {
    self.logger = logger

    // Validate document descriptors
    logger.log(level: .debug, message: "Validating document descriptors...")

    let validationIssues = documentDescriptors.validate() + documentDescriptors
      .map { $0.identifier }
      .duplicates()
      .map { "Multiple DocumentDescriptors have `\($0)` as identifier, every document descriptor must have an unique identifier." }

    guard validationIssues.isEmpty else {
      let errorMessage = "One or more document descriptors are invalid:\n - " + validationIssues.joined(separator: "\n - ")
      logger.log(level: .warn, message: errorMessage)
      throw DocumentStoreError(kind: .documentDescriptionInvalid, message: errorMessage, underlyingError: nil)
    }

    logger.log(level: .debug, message: "Document descriptors valid.")

    // Generate data model
    logger.log(level: .debug, message: "Generating data model...")

    logger.log(level: .trace, message: "  Creating shared attribute `_DocumentData`...")
    let documentDataAttribute = NSAttributeDescription()
    documentDataAttribute.name = DocumentDataAttributeName
    documentDataAttribute.attributeType = .binaryDataAttributeType
    documentDataAttribute.isIndexed = false
    documentDataAttribute.isOptional = false
    documentDataAttribute.allowsExternalBinaryDataStorage = true

    let model = NSManagedObjectModel()
    model.entities = documentDescriptors.map { documentDescriptor in
      logger.log(level: .trace, message: "  Creating entity `\(documentDescriptor.identifier)`...")

      let indexAttributes = documentDescriptor.indices.map { index -> NSAttributeDescription in
        logger.log(level: .trace, message: "    Creating attribute `\(index.identifier)` of type \(index.storageType.attributeType)...")

        let attribute = NSAttributeDescription()
        attribute.name = index.identifier
        attribute.attributeType = index.storageType.attributeType
        attribute.isIndexed = true
        attribute.isOptional = false
        attribute.allowsExternalBinaryDataStorage = false
        return attribute
      }

      let entity = NSEntityDescription()
      entity.name = documentDescriptor.identifier
      entity.properties = [documentDataAttribute] + indexAttributes
      return entity
    }

    logger.log(level: .debug, message: "Model generation finished.")

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
    persistentContainer.performBackgroundTask { [logger] context in
      do {
        try context.setQueryGenerationFrom(NSQueryGenerationToken.current)
      } catch let error {
        logger.log(level: .warn, message: "Failed to pin transaction, this could lead to inconsistent read operations.", error: error)
      }

      let transaction = ReadWriteTransaction(context: context, logger: logger)
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
