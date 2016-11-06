//
//  DocumentDescriptor.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 04-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

public struct DocumentDescriptor<DocumentType: Document> {
  let identifier: String
  let indices: [AnyIndex<DocumentType>]

  public init(identifier: String, indices: [AnyIndex<DocumentType>]) {
    self.identifier = identifier
    self.indices = indices
  }

  public func eraseType() -> AnyDocumentDescriptor {
    return AnyDocumentDescriptor(descriptor: self)
  }
}

public struct AnyDocumentDescriptor: Validatable {
  let identifier: String
  let indices: [UntypedAnyIndex]

  public init<DocumentType>(descriptor: DocumentDescriptor<DocumentType>) {
    self.identifier = descriptor.identifier
    self.indices = descriptor.indices.map(UntypedAnyIndex.init)
  }

  func validate() -> [ValidationIssue] {
    var issues: [ValidationIssue] = []

    // Identifiers may not start with `_`
    if identifier.characters.first == "_" {
      issues.append("`\(identifier)` is an invalid identifier DocumentDescriptor, identifiers may not start with an `_`.")
    }

    // Indices also should be valid
    issues += indices.flatMap { $0.validate() }

    // Two indices may not have the same identifier
    issues += indices
      .map { $0.identifier }
      .duplicates()
      .map {
        "DocumentDescriptor `\(identifier)` has multiple indices with `\($0)` as identifier, every index identifier must be unique."
      }

    return issues
  }
}
