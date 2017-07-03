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

  fileprivate init(foundationExpression: NSExpression) {
    self.foundationExpression = foundationExpression
  }

  init(storageInformation: AnyStorageInformation<DocumentType>) {
    foundationExpression = NSExpression(forKeyPath: storageInformation.propertyName.keyPath)
  }

  /// Create an `Expression` for a constant value.
  ///
  /// - Parameter value: The value to represent
  public init(forConstantValue value: ValueType) {
    self.init(foundationExpression: NSExpression(forConstantValue: value))
  }

  /// Create an `Expression` for `StorageInformation`.
  ///
  /// - Parameter storageInformation: The `StorageInformation` to represent
  public init(storageInformation: StorageInformation<DocumentType, ValueType>) {
    self.init(foundationExpression: NSExpression(forKeyPath: storageInformation.propertyName.keyPath))
  }
}
