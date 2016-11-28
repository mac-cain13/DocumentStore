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
  public let resolver: (DocumentType) -> ValueType

  /// Create an `Index`.
  ///
  /// - Warning: Changing the name or ValueType of this `Index` will trigger a repopulation
  ///            of this index for all documents this `Index` is related to. This can be time 
  ///            consuming.
  ///
  /// - Parameters:
  ///   - name: Unique unchangable (within one document) identifier
  ///   - resolver: Resolver to get the value for this `Index` from a `Document` instance
  public init(name: String, resolver: @escaping (DocumentType) -> ValueType) {
    self.storageInformation = StorageInformation(propertyName: .userDefined(name))
    self.resolver = resolver
  }

  /// Type erasure for `Index` by hiding the `StorableValue`.
  ///
  /// - Note: This is useful since you can't put a `Index<Document, String>` and a 
  ///         `Index<Document, Bool>` together in a sequence. The returned `AnyIndex` will contain 
  ///         all information of this `Index`, but since both indices will become 
  ///         `AnyIndex<Document>` you also will be possible to put them both in for example an 
  ///         array.
  ///
  /// - Returns: `AnyIndex` wrapping this `Index`
  public func eraseType() -> AnyIndex<DocumentType> {
    return AnyIndex(index: self)
  }
}

/// Type erased version of an `Index`.
public struct AnyIndex<DocumentType: Document> {
  let storageInformation: AnyStorageInformation<DocumentType>
  let resolver: (DocumentType) -> Any

  public init<ValueType: StorableValue>(index: Index<DocumentType, ValueType>) {
    self.storageInformation = AnyStorageInformation(storageInformation: index.storageInformation)
    self.resolver = index.resolver
  }
}
