//
//  Index.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 03-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

/// Index for a `Document` used in a `Query` to filter and order `Document`s in an efficient way.
public struct Index<DocumentType: Document, ValueType: StorableValue>: Storable {
  public let storageInformation: StorageInformation<DocumentType, ValueType>
  public let resolver: (DocumentType) -> ValueType?

  /// Create an `Index`.
  ///
  /// - Warning: Changing the name or ValueType of this `Index` will trigger a repopulation
  ///            of this index for all documents this `Index` is related to. This can be time 
  ///            consuming.
  ///
  /// - Parameters:
  ///   - name: Unique unchangable (within one document) identifier
  ///   - resolver: Resolver to get the value for this `Index` from a `Document` instance
  public init(name: String, resolver: @escaping (DocumentType) -> ValueType?) {
    self.storageInformation = StorageInformation(propertyName: .userDefined(name), isOptional: true)
    self.resolver = resolver
  }
}

/// Type erased version of an `Index`.
public struct AnyIndex<DocumentType: Document> {
  let storageInformation: AnyStorageInformation<DocumentType>
  let resolver: (DocumentType) -> Any?

  // TODO: Docs
  public init<ValueType: StorableValue>(from index: Index<DocumentType, ValueType>) {
    self.storageInformation = AnyStorageInformation(storageInformation: index.storageInformation)
    self.resolver = index.resolver
  }

  init<ValueType: StorableValue>(from identifier: Identifier<DocumentType, ValueType>) {
    self.storageInformation = AnyStorageInformation(storageInformation: identifier.storageInformation)
    self.resolver = identifier.resolver
  }
}
