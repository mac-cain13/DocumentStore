//
//  MockDocument.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 27-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation
@testable import DocumentStore

struct MockDocument: Document {
  static let isTest = Index<MockDocument, Bool>(name: "") { _ in false }
  static let documentDescriptor = DocumentDescriptor<MockDocument>(name: "", indices: [])

  func serializeDocument() throws -> Data {
    return Data()
  }

  static func deserializeDocument(from data: Data) throws -> MockDocument {
    return MockDocument()
  }
}
