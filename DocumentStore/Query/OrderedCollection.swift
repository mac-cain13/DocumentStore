//
//  OrderedCollection.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 08-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation
import CoreData

/// An `OrderedCollection` of a single type of `Document`s that can be filtered and ordered.
public struct OrderedCollection<Type: Document>: Collection {
  /// The type of `Document` that is represented.
  public typealias DocumentType = Type

  /// The `SortDescriptor`s that should be used to order the `Collection`
  internal(set) public var sortDescriptors: [SortDescriptor<DocumentType>]

  /// The `Predicate` that should be used to filter the `Collection`.
  internal(set) public var predicate: Predicate<DocumentType>?

  /// The number of matching items to skip.
  internal(set) public var skip: UInt

  /// The maximum number of items that may be returned.
  internal(set) public var limit: UInt?

  /// Create `OrderedCollection` from another `Collection` and order it.
  ///
  /// - Parameters:
  ///   - collection: The `Collection` that should be ordered
  ///   - sortDescriptors: The `SortDescriptor`s to apply
  init<CollectionType: Collection>(collection: CollectionType, sortDescriptors: [SortDescriptor<DocumentType>]) where CollectionType.DocumentType == DocumentType {
    self.sortDescriptors = sortDescriptors
    self.predicate = collection.predicate
    self.skip = collection.skip
    self.limit = collection.limit
  }

  /// Apply an extra ordering to the collection leaving previous orderings intact.
  ///
  /// Example: A `Collection` of the `Document`s with the `Index`es 'age' and 'name' 
  ///          [(2, c), (1, b), (2, a)] on `ordered { $0.age.ascending() }` will become 
  ///          [(1, b), (2, c), (2, a)]. `thenOrdered { $0.name.ascending() }` will then become 
  ///          [(1, b), (2, a), (2, c)].
  ///
  /// - Parameter closure: Closure that returns the `SortDescriptor` to order by
  /// - Returns: An `OrderedCollection` ordered by the `SortDescriptor`
  public func thenOrdered(by closure: (DocumentType.Type) -> SortDescriptor<DocumentType>) -> OrderedCollection<DocumentType> {
    var collection = self
    collection.sortDescriptors.append(closure(DocumentType.self))
    return collection
  }
}
