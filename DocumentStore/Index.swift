//
//  Index.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 03-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

public struct Index<DocumentType: Document, ValueType: IndexValueType> {
  let identifier: String
  let resolver: (DocumentType) -> ValueType

  public init(identifier: String, resolver: @escaping (DocumentType) -> ValueType) {
    self.identifier = identifier
    self.resolver = resolver
  }

  public func eraseType() -> AnyIndex<DocumentType> {
    return AnyIndex(index: self)
  }
}

public struct AnyIndex<DocumentType: Document>: Hashable {
  let identifier: String
  let storageType: IndexStorageType
  let resolver: (DocumentType) -> Any

  public var hashValue: Int { return identifier.hashValue }

  public init<ValueType: IndexValueType>(index: Index<DocumentType, ValueType>) {
    self.identifier = index.identifier
    self.storageType = ValueType.indexStorageType
    self.resolver = index.resolver
  }

  public static func == (lhs: AnyIndex<DocumentType>, rhs: AnyIndex<DocumentType>) -> Bool {
    return lhs.identifier == rhs.identifier
  }
}

struct UntypedAnyIndex: Hashable, Validatable {
  let identifier: String
  let storageType: IndexStorageType

  var hashValue: Int { return identifier.hashValue }

  init<DocumentType: Document>(index: AnyIndex<DocumentType>) {
    self.identifier = index.identifier
    self.storageType = index.storageType
  }

  func validate() -> [ValidationIssue] {
    var issues: [ValidationIssue] = []

    // Identifiers may not start with `_`
    if identifier.characters.first == "_" {
      issues.append("`\(identifier)` is an invalid Index identifier, identifiers may not start with an `_`.")
    }

    return issues
  }

  static func == (lhs: UntypedAnyIndex, rhs: UntypedAnyIndex) -> Bool {
    return lhs.identifier == rhs.identifier
  }
}
