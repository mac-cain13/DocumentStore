//
//  DocumentDescriptorArrayBuilder.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 28-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

/// Utility type to build an array of `DocumentDescriptor`s.
public struct DocumentDescriptorArrayBuilder {
  /// The array containing the appended `DocumentDescriptor`s
  public var array: [AnyDocumentDescriptor] = []

  /// Appends a `DocumentDescriptor` to the array.
  ///
  /// - Parameter documentDescriptor: `DocumentDescriptor` to add
  /// - Returns: A `DocumentDescriptorArrayBuilder` with the given `DocumentDescriptor` added to the array
  public func append<DocumentType>(_ documentDescriptor: DocumentDescriptor<DocumentType>) -> DocumentDescriptorArrayBuilder {
    var builder = self
    builder.array.append(AnyDocumentDescriptor(from: documentDescriptor))
    return builder
  }
}
