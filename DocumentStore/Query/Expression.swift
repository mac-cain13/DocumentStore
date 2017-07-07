//
//  Expression.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 05-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

/// `Expression` that can be used to build a `Predicate`.
public struct Expression<DocumentType: Document, ValueType: IndexableValue> {
  let foundationExpression: NSExpression

  init(forIndex index: PartialIndex<DocumentType>) {
    foundationExpression = NSExpression(forKeyPath: index.storageInformation.propertyName.keyPath)
  }

  /// `Expression` that expresses the `Index` to use in a `Predicate`.
  ///
  /// - Parameters:
  ///   - index: `Index` to express
  /// - Returns: An `Expression` representing the given index
  public init(forIndex index: Index<DocumentType, ValueType>) {
    foundationExpression = NSExpression(forKeyPath: index.storageInformation.propertyName.keyPath)
  }

  /// `Expression` that expresses the `Identifier` to use in a `Predicate`.
  ///
  /// - Parameters:
  ///   - identifier: `Identifier` to express
  /// - Returns: An `Expression` representing the given identifier
  public init(forIdentifier identifier: Identifier<DocumentType, ValueType>) {
    self.init(forIndex: identifier.index)
  }

  /// Create an `Expression` for a constant value.
  ///
  /// - Parameter value: The value to represent
  public init(forConstantValue value: ValueType) {
    foundationExpression = NSExpression(forConstantValue: value)
  }
}
