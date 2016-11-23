//
//  ReadTransaction.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 12-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

/// A transaction on a `DocumentStore` that only can perform reads, no writes are possible.
public class ReadTransaction: ReadableTransaction {
  private let transaction: ReadableTransaction

  init(transaction: ReadableTransaction) {
    self.transaction = transaction
  }

  /// Count the number of `Document`s matching the given `Query`
  ///
  /// - Precondition: The `DocumentDescriptor` of the `Document`s you are counting must be
  ///                 registered with the `DocumentStore` the given `ReadTransaction` is associated
  ///                 with. If this isn't the case a `TransactionError.documentStoreError` is thrown
  ///                 the `DocumentStoreError` will be of kind `documentDescriptionNotRegistered`.
  ///
  /// - Parameter query: The `Query` to match the documents against
  /// - Returns: Number of `Document`s
  /// - Throws: `TransactionError` on all failures
  public func count<DocumentType>(matching query: Query<DocumentType>) throws -> Int {
    return try transaction.count(matching: query)
  }

  /// Array of the `Document`s matching the given `Query`.
  ///
  /// - Precondition: The `DocumentDescriptor` of the `Document`s you are fetching must be
  ///                 registered with the `DocumentStore` the given `ReadTransaction` is associated
  ///                 with. If this isn't the case a `TransactionError.documentStoreError` is thrown
  ///                 the `DocumentStoreError` will be of kind `documentDescriptionNotRegistered`.
  ///
  /// - Parameter query: The `Query` to match the documents against
  /// - Returns: Array of the `Document`s represented
  /// - Throws: `TransactionError` on all failures
  public func fetch<DocumentType>(matching query: Query<DocumentType>) throws -> [DocumentType] {
    return try transaction.fetch(matching: query)
  }

  /// First `Document` matching the given `Query`.
  ///
  /// - Precondition: The `DocumentDescriptor` of the `Document` you are fetching must be
  ///                 registered with the `DocumentStore` the given `ReadTransaction` is associated
  ///                 with. If this isn't the case a `TransactionError.documentStoreError` is thrown
  ///                 the `DocumentStoreError` will be of kind `documentDescriptionNotRegistered`.
  ///
  /// - Parameter query: The `Query` to match the documents against
  /// - Returns: First matching `Document` if any
  /// - Throws: `TransactionError` on all failures
  public func fetchFirst<DocumentType>(matching query: Query<DocumentType>) throws -> DocumentType? {
    return try transaction.fetch(matching: query.limited(upTo: 1)).first
  }
}
