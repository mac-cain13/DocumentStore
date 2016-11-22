//
//  Collection.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 12-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

/// Alias solely for testing
internal typealias DocumentStoreCollection = Collection

/// A `Collection` of a single type of `Document`s that can be filtered and ordered.
protocol Collection {
  associatedtype DocumentType: Document

  var predicate: Predicate<DocumentType>? { get set }
  var skip: UInt { get set }
  var limit: UInt? { get set }
}

extension Collection {

  // MARK: Limiting

  /// Skip a number of `Document`s in the `Collection`.
  ///
  /// - Note: Given the `Document`s [a, b, c, d] `skipping(upTo: 2)` will result in a `Collection`
  ///         of [c, d]. Then again performing an `skipping(upTo: 1)` on this `Collection` will
  ///         return [d].
  ///
  /// - Parameter numberOfItems: Number of items to skip.
  /// - Returns: A collection skipping the given number of items.
  public func skipping(upTo numberOfItems: UInt) -> Self {
    var collection = self
    collection.skip = skip + numberOfItems
    return collection
  }

  /// Limits the number of `Document`s in the `Collection`.
  ///
  /// - Note: Given the `Document`s [a, b, c, d] `limiting(upTo: 2)` will result in a `Collection`
  ///         of [a, b].
  ///
  /// - Parameter numberOfItems: Maximum number of items that this collection may contain
  /// - Returns: A collection with not more then the given number of items
  public func limited(upTo numberOfItems: UInt) -> Self {
    var collection = self
    collection.limit = min(limit ?? UInt.max, numberOfItems)
    return collection
  }

  // MARK: Filtering

  /// Filters the `Collection` by the returned `Predicate`.
  ///
  /// - Note: Given the `Document`s with an age `Index` of [16, 21, 23, 31]
  ///         `filtering { $0.age > 18 }` will result in a collection of [21, 23, 31]. Then again
  ///         performing `filtering { $0.age < 30 }` will return [21, 23].
  ///
  /// - Parameter isIncluded: Closure that returns the `Predicate` to filter by
  /// - Returns: A collection filtered by the predicate
  public func filtered(using predicate: (DocumentType.Type) -> Predicate<DocumentType>) -> Self {
    var collection = self
    collection.predicate = collection.predicate && predicate(DocumentType.self)
    return collection
  }

  // MARK: Sorting

  /// Sort the `Collection` by the returned `SortDescriptor`.
  ///
  /// - Note: Given the `Document`s with a name `Index` of [d, c, a, b]
  ///         `ordered { $0.name.ascending() }` will result in a collection of [a, b, c, d].
  ///
  /// - Important: A second call to `sorted(by:)` will remove the first sorting, to apply multiple
  ///              `SortDescriptor`s use `thenSorted(by:)`.
  ///
  /// - Parameter sortDescriptor: Closure that returns the `SortDescriptor` to order by
  /// - Returns: An `OrderedCollection` ordered by the `SortDescriptor`
  public func sorted(by sortDescriptor: (DocumentType.Type) -> SortDescriptor<DocumentType>) -> OrderedCollection<DocumentType> {
    return OrderedCollection(collection: self, sortDescriptors: [sortDescriptor(DocumentType.self)])
  }

  // MARK: Fetching

  /// Count the number of `Document`s in this `Collection`
  ///
  /// - Precondition: The `DocumentDescriptor` of the `Document`s you are counting must be 
  ///                 registered with the `DocumentStore` the given `ReadTransaction` is associated 
  ///                 with. If this isn't the case a `TransactionError.documentStoreError` is thrown
  ///                 the `DocumentStoreError` will be of kind `documentDescriptionNotRegistered`.
  ///
  /// - Parameter transaction: The `ReadTransaction` to perform the count in
  /// - Returns: Number of `Document`s
  /// - Throws: `TransactionError` on all failures
  public func count(in transaction: ReadTransaction) throws -> Int {
    return try transaction.count(self)
  }

  /// Array of the `Document`s represented by this `Collection`.
  ///
  /// - Precondition: The `DocumentDescriptor` of the `Document`s you are fetching must be
  ///                 registered with the `DocumentStore` the given `ReadTransaction` is associated
  ///                 with. If this isn't the case a `TransactionError.documentStoreError` is thrown
  ///                 the `DocumentStoreError` will be of kind `documentDescriptionNotRegistered`.
  ///
  /// - Parameter transaction: The `ReadTransaction` to perform the fetch in
  /// - Returns: Array of the `Document`s represented
  /// - Throws: `TransactionError` on all failures
  public func array(in transaction: ReadTransaction) throws -> [DocumentType] {
    return try transaction.fetch(self)
  }

  /// First `Document` represented by this `Collection`.
  ///
  /// - Precondition: The `DocumentDescriptor` of the `Document` you are fetching must be
  ///                 registered with the `DocumentStore` the given `ReadTransaction` is associated
  ///                 with. If this isn't the case a `TransactionError.documentStoreError` is thrown
  ///                 the `DocumentStoreError` will be of kind `documentDescriptionNotRegistered`.
  ///
  /// - Parameter transaction: The `ReadTransaction` to perform the fetch in
  /// - Returns: First `Document` represented by the collection if any
  /// - Throws: `TransactionError` on all failures
  public func first(in transaction: ReadTransaction) throws -> DocumentType? {
    return try limited(upTo: 1).array(in: transaction).first
  }

  /// Delete all `Document`s represented by this `Collection`.
  ///
  /// - Precondition: The `DocumentDescriptor` of the `Document`s you are deleting must be
  ///                 registered with the `DocumentStore` the given `ReadTransaction` is associated
  ///                 with. If this isn't the case a `TransactionError.documentStoreError` is thrown
  ///                 the `DocumentStoreError` will be of kind `documentDescriptionNotRegistered`.
  ///
  /// - Parameter transaction: The `ReadWriteTransaction` to perform the fetch in
  /// - Returns: Number of deleted `Document`s
  /// - Throws: `TransactionError` on all failures
  @discardableResult
  public func delete(in transaction: ReadWriteTransaction) throws -> Int {
    return try transaction.delete(self)
  }
}
