//
//  IndexArrayBuilder.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 28-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

/// Utility type to build an array of `DocumentDescriptor`s.
public struct IndexArrayBuilder<DocumentType: Document> {
  /// The array containing the appended `DocumentDescriptor`s
  public var array: [AnyIndex<DocumentType>] = []

  /// Appends an `Index` to the array.
  ///
  /// - Parameter index: `Index` to add
  /// - Returns: A `IndexArrayBuilder` with the given `Index` added to the array
  public func append<ValueType>(_ index: Index<DocumentType, ValueType>) -> IndexArrayBuilder<DocumentType> {
    var builder = self
    builder.array.append(AnyIndex(from: index))
    return builder
  }
}
