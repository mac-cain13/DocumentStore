//
//  Query.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 12-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

/// A `Query` that can filter and order a single type of `Document` in a certain transaction.
///
/// - Note: Sorting is always done before limiting the results. So the order of calling `sorted` and
///         `skipping`/`limited` does not matter, they only change the query object that is 
///         evaluated at once when you execute it in a transaction.
public struct Query<DocumentType: Document> {

  // MARK: Properties

  /// Optional `Predicate` used to filter the `Document`s
  public var predicate: Predicate<DocumentType>?

  /// `SortDescriptor`s used to sort the `Document`s
  public var sortDescriptors: [SortDescriptor<DocumentType>]

  /// Number of `Document`s that this `Query` will skip in the result
  public var skip: UInt

  /// An optional maximum number of `Document`s that this `Query` will match
  public var limit: UInt?

  // MARK: Initializers

  /// Initializes a `Query` with no filters, sortings or other limitations.
  public init() {
    predicate = nil
    sortDescriptors = []
    skip = 0
    limit = nil
  }

  /// Initialize a `Query` passing in the initial filter, sortings and limitations.
  ///
  /// - Parameters:
  ///   - predicate: Optional `Predicate` used to filter the `Document`s
  ///   - sortDescriptors: `SortDescriptor`s used to sort the `Document`s
  ///   - skip: Number of `Document`s that this `Query` will skip in the result
  ///   - limit: An optional maximum number of `Document`s that this `Query` will match
  public init(predicate: Predicate<DocumentType>?, sortDescriptors: [SortDescriptor<DocumentType>], skip: UInt, limit: UInt?) {
    self.predicate = predicate
    self.sortDescriptors = sortDescriptors
    self.skip = skip
    self.limit = limit
  }

  // MARK: Limiting

  /// Skip the first number of `Document`s that are matched by this `Query`.
  ///
  /// - Note: Given the `Document`s [a, b, c, d] `skipping(upTo: 2)` will result in a `Query` matching
  ///         of [c, d]. Then again performing an `skipping(upTo: 1)` on this `Query` will make it
  ///         match [d].
  ///
  /// - Parameter numberOfItems: Number of items to skip.
  /// - Returns: A `Query` skipping the given number of items.
  public func skipping(upTo numberOfItems: UInt) -> Query<DocumentType> {
    var query = self
    query.skip = skip + numberOfItems
    return query
  }

  /// Limits the number of `Document`s the `Query` will match.
  ///
  /// - Note: Given the `Document`s [a, b, c, d] `limiting(upTo: 2)` will result in a `Query`
  ///         matching [a, b]. Then `limiting(upTo: 3)` will still match only [a, b].
  ///
  /// - Parameter numberOfItems: Maximum number of items that this `Query` will match
  /// - Returns: A `Query` matching not more then the given number of items
  public func limited(upTo numberOfItems: UInt) -> Query<DocumentType> {
    var query = self
    query.limit = min(limit ?? UInt.max, numberOfItems)
    return query
  }

  // MARK: Filtering

  /// Filters the `Document`s matched by the `Query` using the returned `Predicate`.
  ///
  /// - Note: Given the `Document`s with an age `Index` of [16, 21, 23, 31]
  ///         `filtering { $0.age > 18 }` will result in a `Query` matching [21, 23, 31]. Then again
  ///         performing `filtering { $0.age < 30 }` will return [21, 23].
  ///
  /// - Parameter isIncluded: Closure that returns the `Predicate` to filter by
  /// - Returns: A `Query` that only matches `Document`s passing the predicate
  public func filtered(using predicate: (DocumentType.Type) -> Predicate<DocumentType>) -> Query<DocumentType> {
    var query = self
    query.predicate = query.predicate && predicate(DocumentType.self)
    return query
  }

  // MARK: Sorting

  /// Sort the `Query` by the returned `SortDescriptor`.
  ///
  /// - Note: Given the `Document`s with a name `Index` of [d, c, a, b]
  ///         `ordered { $0.name.ascending() }` will result in a `Query` matching [a, b, c, d].
  ///
  /// - Important: A second call to `sorted(by:)` will remove the first sorting, to apply multiple
  ///              `SortDescriptor`s use `thenSorted(by:)`.
  ///
  /// - Parameter sortDescriptor: Closure that returns the `SortDescriptor` to order by
  /// - Returns: A `Query` where matching `Document`s are ordered by the `SortDescriptor`
  public func sorted(by sortDescriptor: (DocumentType.Type) -> SortDescriptor<DocumentType>) -> Query<DocumentType> {
    var query = self
    query.sortDescriptors = [sortDescriptor(DocumentType.self)]
    return query
  }

  /// Apply a subsequent sorting to the `Document`s matching this `Query` leaving previous sorting
  /// instructions intact.
  ///
  /// Example: A `Query` matching the `Document`s with the `Index`es 'age' and 'name'
  ///          [(2, c), (1, b), (2, a)] on `sorted { $0.age.ascending() }` will become
  ///          [(1, b), (2, c), (2, a)]. `thenSorted { $0.name.ascending() }` will then become
  ///          [(1, b), (2, a), (2, c)].
  ///
  /// - Parameter closure: Closure that returns the `SortDescriptor` to sort by
  /// - Returns: A `Query` that sorts `Document`s subsequently by the given `SortDescriptor`
  public func thenSorted(by closure: (DocumentType.Type) -> SortDescriptor<DocumentType>) -> Query<DocumentType> {
    var query = self
    query.sortDescriptors.append(closure(DocumentType.self))
    return query
  }
}
