//
//  Index.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 03-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

/// Index for a `Document` used in a `Query` to filter and order `Document`s in an efficient way.
public struct Index<DocumentType: Document, ValueType: IndexableValue> {
  public let storageInformation: StorageInformation<DocumentType, ValueType>
  public let resolver: (DocumentType) -> ValueType?

  /// Create an `Index`
  ///
  /// - Warning: Changing the name or ValueType of this `Index` will trigger a repopulation
  ///            of this index for all documents this `Index` is related to. This can be time 
  ///            consuming.
  ///
  /// - Parameters:
  ///   - name: Unique (within one document) unchangable identifier
  ///   - resolver: Resolver to get the value for this `Index` from a `Document` instance
  public init(name: String, resolver: @escaping (DocumentType) -> ValueType?) {
    self.storageInformation = StorageInformation(propertyName: .userDefined(name), isOptional: true, sourceKeyPath: nil)
    self.resolver = resolver
  }

  /// Create an `Index` with a `KeyPath`
  ///
  /// - Warning: Changing the name or ValueType of this `Index` will trigger a repopulation
  ///            of this index for all documents this `Index` is related to. This can be time
  ///            consuming.
  ///
  /// - Parameters:
  ///   - name: Unique (within one document) unchangable identifier
  ///   - resolver: Resolver to get the value for this `Index` from a `Document` instance
  public init(name: String, keyPath: KeyPath<DocumentType, ValueType>) {
    self.storageInformation = StorageInformation(propertyName: .userDefined(name), isOptional: true, sourceKeyPath: keyPath)
    self.resolver = { document in document[keyPath: keyPath] }
  }
}

/// Type eraser for `Index` to make it possible to store them in for example an array.
public struct AnyIndex<DocumentType: Document> {
  let storageInformation: AnyStorageInformation<DocumentType>
  let resolver: (DocumentType) -> Any?

  /// Type erase an `Index`.
  ///
  /// - Parameter index: The `Index` to type erase
  /// - SeeAlso: `IndexArrayBuilder`
  public init<ValueType>(from index: Index<DocumentType, ValueType>) {
    self.storageInformation = AnyStorageInformation(from: index.storageInformation)
    self.resolver = index.resolver
  }

  init<ValueType>(from identifier: Identifier<DocumentType, ValueType>) {
    self.storageInformation = AnyStorageInformation(from: identifier.storageInformation)
    self.resolver = identifier.resolver
  }
}
