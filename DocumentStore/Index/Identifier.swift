//
//  Identifier.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 28-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

/// Describes a unique `Identifier` for a `Document`, think of it as the primary key of the document.
public struct Identifier<DocumentType: Document, ValueType: IndexableValue> {
  public let storageInformation: StorageInformation<DocumentType, ValueType>
  public let resolver: (DocumentType) -> ValueType?

  /// Intialize an `Identifier`
  ///
  /// - Warning: The `resolver` must always return the same identifying value for the same `Document`.
  ///            Not doing so will result in undefined behaviour of the `DocumentStore`.
  ///
  /// - Parameter resolver: Given a `Document` the resolver should return the unique identifier
  public init(resolver: @escaping (DocumentType) -> ValueType) {
    self.storageInformation = StorageInformation(propertyName: .libraryDefined(DocumentIdentifierAttributeName), isOptional: false, sourceKeyPath: nil)
    self.resolver = resolver
  }

  /// Intialize an `Identifier` with a `KeyPath`
  ///
  /// - Warning: The `keyPath` must always return the same identifying value for the same `Document`.
  ///            Not doing so will result in undefined behaviour of the `DocumentStore`.
  ///
  /// - Parameter keyPath: Given a `Document` the key path should return the unique identifier
  public init(keyPath: KeyPath<DocumentType, ValueType>) {
    self.storageInformation = StorageInformation(propertyName: .libraryDefined(DocumentIdentifierAttributeName), isOptional: false, sourceKeyPath: keyPath)
    self.resolver = { document in document[keyPath: keyPath] }
  }
}
