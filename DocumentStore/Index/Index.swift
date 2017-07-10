//
//  Index.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 03-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

/// Index for a `Document` used in a `Query` to filter and order `Document`s in an efficient way.
public class Index<DocumentType: Document, ValueType: IndexableValue>: PartialIndex<DocumentType> {
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
    let storageInformation = StorageInformation(
      documentNameResolver: { DocumentType.documentDescriptor.name },
      propertyName: PropertyName.userDefined(name),
      storageType: ValueType.storageType,
      isOptional: true,
      sourceKeyPath: nil
    )
    let resolver: (Any) -> Any? = {
      guard let document = $0 as? DocumentType else { fatalError("Index resolver type violation.") }
      return resolver(document)
    }
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
      documentNameResolver: { DocumentType.documentDescriptor.name },
      propertyName: .userDefined(name),
      storageType: ValueType.storageType,
      isOptional: true,
      sourceKeyPath: keyPath
    )
    let resolver: (Any) -> Any? = {
      guard let document = $0 as? DocumentType else { fatalError("Index resolver type violation.") }
      return document[keyPath: keyPath]
    }
    super.init(storageInformation: storageInformation, resolver: resolver)
  }

  init(storageInformation: StorageInformation, resolver: @escaping (DocumentType) -> ValueType?) {
    let resolver: (Any) -> Any? = {
      guard let document = $0 as? DocumentType else { fatalError("Index resolver type violation.") }
      return resolver(document)
    }
    super.init(storageInformation: storageInformation, resolver: resolver)
  }
}

/// Type eraser for `Index` to make it possible to store them in for example an array.
public class PartialIndex<DocumentType: Document>: AnyIndex {}

public class AnyIndex {
  let storageInformation: StorageInformation
  let resolver: (Any) -> Any?

  init(storageInformation: StorageInformation, resolver: @escaping (Any) -> Any?) {
    self.storageInformation = storageInformation
    self.resolver = resolver
  }
}
