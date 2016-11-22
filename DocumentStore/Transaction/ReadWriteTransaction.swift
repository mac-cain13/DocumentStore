//
//  ReadWriteTransaction.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 07-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

/// A transaction on a `DocumentStore` that can perform reads and writes.
public final class ReadWriteTransaction: ReadTransaction, ReadWritableTransaction {
  private let transaction: ReadWritableTransaction

  init(transaction: ReadWritableTransaction) {
    self.transaction = transaction
    super.init(transaction: transaction)
  }

  /// Add the given `Document` to the `DocumentStore` this `ReadWriteTransaction` is associated with.
  ///
  /// - Precondition: The `DocumentDescriptor` of the `Document` you are adding must be registered
  ///                 with the `DocumentStore` the given `ReadTransaction` is associated with. If
  ///                 this isn't the case a `TransactionError.documentStoreError` is thrown the
  ///                 `DocumentStoreError` will be of kind `documentDescriptionNotRegistered`.
  ///
  /// - Parameter document: `Document` to add to the `DocumentStore`
  /// - Throws: `TransactionError` on all failures
  public func add<DocumentType: Document>(document: DocumentType) throws {
    try transaction.add(document: document)
  }

  @discardableResult
  func delete<CollectionType: Collection>(_ collection: CollectionType) throws -> Int {
    return try transaction.delete(collection)
  }

  func saveChanges() throws {
    try transaction.saveChanges()
  }
}
