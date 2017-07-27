//
//  MockDocument.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 27-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation
@testable import DocumentStore

struct MockDocument: Document, Codable {
  static let isTest = Index<MockDocument, Bool>(name: "") { _ in false }
  static let documentDescriptor = DocumentDescriptor<MockDocument>(name: "", identifier: Identifier { _ in return UUID().uuidString }, indices: [])

  func serializeDocument() throws -> Data {
    return Data()
  }

  static func deserializeDocument(from data: Data) throws -> MockDocument {
    return MockDocument()
  }
}
