//
//  Index.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 03-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

/// Index for a `Document` used to filter and order a `Collection` in an efficient way.
public struct Index<DocumentType: Document, ValueType: IndexValueType> {
  let identifier: String
  let resolver: (DocumentType) -> ValueType

  /// Create an `Index`.
  ///
  /// Warning: Do never change the identifier, this is the only unique reference there is for the
  ///          storage system to know what `Index` you are describing. Doing so will trigger a
  ///          repopulation of this index for all documents in the collection.
  ///
  /// - Parameters:
  ///   - identifier: Unique unchangable (within one document) identifier
  ///   - resolver: Resolver to get the value for this `Index` from a `Document` instance
  public init(identifier: String, resolver: @escaping (DocumentType) -> ValueType) {
    self.identifier = identifier
    self.resolver = resolver
  }

  /// Type erasure for use of an `Index` in a list.
  ///
  /// - Returns: `AnyIndex` wrapping this `Index`
  public func eraseType() -> AnyIndex<DocumentType> {
    return AnyIndex(index: self)
  }
}

/// Type erased version of an `Index`.
public struct AnyIndex<DocumentType: Document> {
  let identifier: String
  let storageType: IndexStorageType
  let resolver: (DocumentType) -> Any

  init<ValueType: IndexValueType>(index: Index<DocumentType, ValueType>) {
    self.identifier = index.identifier
    self.storageType = ValueType.indexStorageType
    self.resolver = index.resolver
  }
}

struct UntypedAnyIndex: Validatable, Equatable {
  let identifier: String
  let storageType: IndexStorageType

  init<DocumentType: Document>(index: AnyIndex<DocumentType>) {
    self.identifier = index.identifier
    self.storageType = index.storageType
  }

  func validate() -> [ValidationIssue] {
    var issues: [ValidationIssue] = []

    // Identifiers may not be empty
    if identifier.isEmpty {
      issues.append("Index identifiers may not be empty.")
    }

    // Identifiers may not start with `_`
    if identifier.characters.first == "_" {
      issues.append("`\(identifier)` is an invalid Index identifier, identifiers may not start with an `_`.")
    }

    return issues
  }

  static func == (lhs: UntypedAnyIndex, rhs: UntypedAnyIndex) -> Bool {
    return lhs.identifier == rhs.identifier && lhs.storageType == rhs.storageType
  }
}
