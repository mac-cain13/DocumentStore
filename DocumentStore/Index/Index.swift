//
//  Index.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 03-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

/// Index for a `Document` used in a `Query` to filter and order `Document`s in an efficient way.
public class Index<DocumentType: Document, ValueType: IndexableValue>: AnyIndex<DocumentType> {
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
    let storageInformation = StorageInformation<DocumentType>(
      propertyName: PropertyName.userDefined(name),
      storageType: ValueType.storageType,
      isOptional: true,
      sourceKeyPath: nil
    )
    super.init(storageInformation: storageInformation, resolver: resolver)
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
    let storageInformation = StorageInformation(
      propertyName: .userDefined(name),
      storageType: ValueType.storageType,
      isOptional: true,
      sourceKeyPath: keyPath
    )
    super.init(storageInformation: storageInformation) { document in document[keyPath: keyPath] }
  }
}

/// Type eraser for `Index` to make it possible to store them in for example an array.
public class AnyIndex<DocumentType: Document> {
  let storageInformation: StorageInformation<DocumentType>
  let resolver: (DocumentType) -> Any?

  init(storageInformation: StorageInformation<DocumentType>, resolver: @escaping (DocumentType) -> Any?) {
    self.storageInformation = storageInformation
    self.resolver = resolver
  }
}
