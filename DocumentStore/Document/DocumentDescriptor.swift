//
//  DocumentDescriptor.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 04-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

/// Description of a `Document` that among other things identifies it.
public class DocumentDescriptor<DocumentType: Document>: AnyDocumentDescriptor {
  private let typedIdentifier: AnyIndex<DocumentType>
  private let typedIndices: [AnyIndex<DocumentType>]

  /// Create a description of a `Document`
  ///
  /// - Warning: Do never change the name or the returned value of the identifier, those are used as 
  ///            the unique references to your documents in the storage system. Changing them will
  ///            result in data loss!
  ///
  /// - Parameters:
  ///   - name: Unique (within one store) unchangable name of the described `Document`
  ///   - identifier: Unique `Identifier` (for this type of `Document`), used to identify the document
  ///   - indices: List of all indices that should be created for the described `Document`
  public init<IdentifierValueType>(name: String, identifier: Identifier<DocumentType, IdentifierValueType>, indices: [AnyIndex<DocumentType>]) {
    self.typedIdentifier = identifier.index
    self.typedIndices = indices

    super.init(name: name, identifier: identifier.index, indices: indices)
  }

  func findIndex(basedOn keyPath: PartialKeyPath<DocumentType>) -> AnyIndex<DocumentType>? {
    if typedIdentifier.storageInformation.sourceKeyPath == keyPath {
      return typedIdentifier
    }

    return typedIndices.first { index in index.storageInformation.sourceKeyPath == keyPath }
  }
}

/// Type eraser for `DocumentDescriptor` to make it possible to store them in for example an array.
public class AnyDocumentDescriptor: Validatable, Equatable {
  let name: String
  let identifier: TotallyAnyIndex
  let indices: [TotallyAnyIndex]

  init(name: String, identifier: TotallyAnyIndex, indices: [TotallyAnyIndex]) {
    self.name = name
    self.identifier = identifier
    self.indices = indices
  }

  func validate() -> [ValidationIssue] {
    var issues: [ValidationIssue] = []

    // Name may not be empty
    if name.isEmpty {
      issues.append("DocumentDescriptor names may not be empty.")
    }

    // Name may not start with `_`
    if name.characters.first == "_" {
      issues.append("`\(name)` is an invalid DocumentDescriptor name, names may not start with an `_`.")
    }

    // Two indices may not have the same identifier
    issues += indices
      .map { $0.storageInformation.propertyName.keyPath }
      .duplicates()
      .map { "DocumentDescriptor `\(name)` has multiple indices with `\($0)` as name, every index name must be unique." }

    // Two indices may not use the same `KeyPath` (or else querying will break)
    issues += ([identifier] + indices)
      .flatMap { $0.storageInformation.sourceKeyPath }
      .duplicates()
      .map { "DocumentDescriptor `\(name)` has multiple indices using \($0) as the source key path, every index including the identifier must use a unique key path." }

    // Indices also should be valid
    issues += indices.flatMap { $0.storageInformation.validate() }

    return issues
  }

  public static func == (lhs: AnyDocumentDescriptor, rhs: AnyDocumentDescriptor) -> Bool {
    let lhsStorageInformation = lhs.indices.map { $0.storageInformation }
    let rhsStorageInformation = rhs.indices.map { $0.storageInformation }
    return lhs.name == rhs.name && lhsStorageInformation == rhsStorageInformation
  }
}
