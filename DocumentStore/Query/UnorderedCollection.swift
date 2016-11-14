//
//  UnorderedCollection.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 08-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

/// An `UnorderedCollection` of a single type of `Document`s that can be filtered and ordered.
public struct UnorderedCollection<Type: Document>: Collection {
  /// The type of `Document` that is represented.
  public typealias DocumentType = Type

  /// The `Predicate` that should be used to filter the `Collection`.
  internal(set) public var predicate: Predicate<DocumentType>?

  /// The number of matching items to skip.
  internal(set) public var skip: UInt

  /// The maximum number of items that may be returned.
  internal(set) public var limit: UInt?

  /// Create a new `UnorderedCollection`
  init() {
    self.predicate = nil
    self.skip = 0
    self.limit = nil
  }
}
