//
//  DocumentDescriptor.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 04-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

/// Description of a `Document` that among other things identifies it.
public struct DocumentDescriptor<DocumentType: Document> {
  let identifier: String
  let indices: [AnyIndex<DocumentType>]

  /// Create a description of a `Document`
  ///
  /// - Warning: Do never change the identifier, this is the only unique reference there is for the
  ///            storage system to know what `Document` you are describing. Changing it will result
  ///            in data loss!
  ///
  /// - Parameters:
  ///   - identifier: Unique unchangable (within one store) identifier of the described `Document`
  ///   - indices: List of all indices that should be created for the described `Document`
  public init(identifier: String, indices: [AnyIndex<DocumentType>]) {
    self.identifier = identifier
    self.indices = indices
  }

  /// Type erasure for use of a `DocumentDescriptor` in a list.
  ///
  /// - Returns: `AnyDocumentDescriptor` wrapping this descriptor
  public func eraseType() -> AnyDocumentDescriptor {
    return AnyDocumentDescriptor(descriptor: self)
  }
}

/// Type erased version of a `DocumentDescriptor`.
public struct AnyDocumentDescriptor: Validatable, Equatable {
  let identifier: String
  let indices: [UntypedAnyIndex]

  init<DocumentType>(descriptor: DocumentDescriptor<DocumentType>) {
    self.identifier = descriptor.identifier
    self.indices = descriptor.indices.map(UntypedAnyIndex.init)
  }

  func validate() -> [ValidationIssue] {
    var issues: [ValidationIssue] = []

    // Identifiers may not be empty
    if identifier.isEmpty {
      issues.append("DocumentDescriptor identifiers may not be empty.")
    }

    // Identifiers may not start with `_`
    if identifier.characters.first == "_" {
      issues.append("`\(identifier)` is an invalid DocumentDescriptor identifier, identifiers may not start with an `_`.")
    }

    // Two indices may not have the same identifier
    issues += indices
      .map { $0.identifier }
      .duplicates()
      .map { "DocumentDescriptor `\(identifier)` has multiple indices with `\($0)` as identifier, every index identifier must be unique." }

    // Indices also should be valid
    issues += indices.flatMap { $0.validate() }

    return issues
  }

  public static func == (lhs: AnyDocumentDescriptor, rhs: AnyDocumentDescriptor) -> Bool {
    return lhs.identifier == rhs.identifier && lhs.indices == rhs.indices
  }
}
