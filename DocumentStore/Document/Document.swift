//
//  Document.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 03-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

public protocol Document {
  static var documentDescriptor: DocumentDescriptor<Self> { get }

  static func deserializeDocument(from data: Data) throws -> Self
  func serializeDocument() throws -> Data
}

public extension Document {
  public static func all() -> UnorderedCollection<Self> {
    return UnorderedCollection()
  }
}
