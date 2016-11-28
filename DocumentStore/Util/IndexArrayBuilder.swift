//
//  IndexArrayBuilder.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 28-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

// TODO: Docs
public struct IndexArrayBuilder<DocumentType: Document> {
  public var array: [AnyIndex<DocumentType>] = []

  public func append<ValueType: StorableValue>(_ index: Index<DocumentType, ValueType>) -> IndexArrayBuilder<DocumentType> {
    var builder = self
    builder.array.append(AnyIndex(from: index))
    return builder
  }
}
