//
//  Query.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 12-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

// TODO: Fix all comments containing `Collection`
/// A `Collection` of a single type of `Document`s that can be filtered and ordered.
public struct Query<DocumentType: Document> {

  // TODO
  public var predicate: Predicate<DocumentType>?

  // TODO
  public var sortDescriptors: [SortDescriptor<DocumentType>]

  // TODO
  public var skip: UInt

  // TODO
  public var limit: UInt?

  // TODO
  public init() {
    predicate = nil
    sortDescriptors = []
    skip = 0
    limit = nil
  }

  // MARK: Limiting

  /// Skip a number of `Document`s in the `Collection`.
  ///
  /// - Note: Given the `Document`s [a, b, c, d] `skipping(upTo: 2)` will result in a `Collection`
  ///         of [c, d]. Then again performing an `skipping(upTo: 1)` on this `Collection` will
  ///         return [d].
  ///
  /// - Parameter numberOfItems: Number of items to skip.
  /// - Returns: A collection skipping the given number of items.
  public func skipping(upTo numberOfItems: UInt) -> Query<DocumentType> {
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
  public func limited(upTo numberOfItems: UInt) -> Query<DocumentType> {
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
  public func filtered(using predicate: (DocumentType.Type) -> Predicate<DocumentType>) -> Query<DocumentType> {
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
  public func sorted(by sortDescriptor: (DocumentType.Type) -> SortDescriptor<DocumentType>) -> Query<DocumentType> {
    var collection = self
    collection.sortDescriptors = [sortDescriptor(DocumentType.self)]
    return collection
  }

  /// Apply an extra sorting to the collection leaving previous sorting instructions intact.
  ///
  /// Example: A `Collection` of the `Document`s with the `Index`es 'age' and 'name'
  ///          [(2, c), (1, b), (2, a)] on `sorted { $0.age.ascending() }` will become
  ///          [(1, b), (2, c), (2, a)]. `thenSorted { $0.name.ascending() }` will then become
  ///          [(1, b), (2, a), (2, c)].
  ///
  /// - Parameter closure: Closure that returns the `SortDescriptor` to order by
  /// - Returns: An `OrderedCollection` ordered by the `SortDescriptor`
  public func thenSorted(by closure: (DocumentType.Type) -> SortDescriptor<DocumentType>) -> Query<DocumentType> {
    var collection = self
    collection.sortDescriptors.append(closure(DocumentType.self))
    return collection
  }
}
