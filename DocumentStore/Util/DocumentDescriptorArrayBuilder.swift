//
//  DocumentDescriptorArrayBuilder.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 28-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

// TODO: Docs
public struct DocumentDescriptorArrayBuilder {
  public var array: [AnyDocumentDescriptor] = []

  public func append<DocumentType: Document>(_ documentDescriptor: DocumentDescriptor<DocumentType>) -> DocumentDescriptorArrayBuilder {
    var builder = self
    builder.array.append(AnyDocumentDescriptor(from: documentDescriptor))
    return builder
  }
}
