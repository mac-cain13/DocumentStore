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

public struct AnyDocumentDescriptor: Hashable {
  let identifier: String
  let indices: Set<UntypedAnyIndex>

  public var hashValue: Int { return identifier.hashValue }

  public init<DocumentType>(descriptor: DocumentDescriptor<DocumentType>) {
    self.identifier = descriptor.identifier
    self.indices = Set(descriptor.indices.map(UntypedAnyIndex.init))
  }

  public static func ==(lhs: AnyDocumentDescriptor, rhs: AnyDocumentDescriptor) -> Bool {
    return lhs.identifier == rhs.identifier
  }
}
