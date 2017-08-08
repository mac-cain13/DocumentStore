//
//  ReadWriteTransaction.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 07-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

/// A transaction on a `DocumentStore` that can perform reads and writes.
public class ReadWriteTransaction: ReadTransaction, ReadWritableTransaction {
  private let transaction: ReadWritableTransaction

  init(transaction: ReadWritableTransaction) {
    self.transaction = transaction
    super.init(transaction: transaction)
  }

  @discardableResult
  public func insert<DocumentType: Document>(document: DocumentType, mode: InsertMode = .addOrReplace) throws -> Bool {
    return try transaction.insert(document: document, mode: mode)
  }

  /// Delete all `Document`s matching the given `Query`.
  ///
  /// - Precondition: The `DocumentDescriptor` of the `Document`s you are deleting must be
  ///                 registered with the `DocumentStore` the given `ReadTransaction` is associated
  ///                 with. If this isn't the case a `TransactionError.documentStoreError` is thrown
  ///                 the `DocumentStoreError` will be of kind `documentDescriptionNotRegistered`.
  ///
  /// - Parameter query: The `Query` to match the documents against
  /// - Returns: Number of deleted `Document`s
  /// - Throws: `TransactionError` on all failures
  @discardableResult
  public func delete<DocumentType>(matching query: Query<DocumentType>) throws -> Int {
    return try transaction.delete(matching: query)
  }

  @discardableResult
  public func delete<DocumentType: Document>(document: DocumentType) throws -> Bool {
    return try transaction.delete(document: document)
  }

  func persistChanges() throws {
    try transaction.persistChanges()
  }
}
