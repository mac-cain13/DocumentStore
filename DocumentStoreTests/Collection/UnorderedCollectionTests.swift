//
//  UnorderedCollectionTests.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 07-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import XCTest
@testable import DocumentStore

class UnorderedCollectionTests: XCTestCase {

  private var collection = UnorderedCollection<TestDocument>()

  override func setUp() {
    super.setUp()
    collection = UnorderedCollection<TestDocument>()
  }

  func testNoRestrictionsByDefault() {
    XCTAssertNil(collection.predicate)
    XCTAssertEqual(collection.skip, 0)
    XCTAssertNil(collection.limit)
  }
}

private struct TestDocument: Document {
  static var documentDescriptor = DocumentDescriptor<TestDocument>(identifier: "", indices: [])

  func serializeDocument() throws -> Data {
    return Data()
  }

  static func deserializeDocument(from data: Data) throws -> TestDocument {
    return TestDocument()
  }
}
