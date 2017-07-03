//
//  Document.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 03-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

/// A type that provides an interface to transfer types to a document store and back.
public protocol Document: Codable {
  /// Description that indentifies the document and determens how it should be indexed.
  static var documentDescriptor: DocumentDescriptor<Self> { get }
}
