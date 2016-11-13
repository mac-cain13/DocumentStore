//
//  DocumentTests.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 07-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import XCTest
@testable import DocumentStore

class DocumentTests: XCTestCase {

  func testAllHasNoRestrictions() {
    let collectionFromDocument = TestDocument.all()

    XCTAssertNil(collectionFromDocument.predicate)
    XCTAssertEqual(collectionFromDocument.skip, 0)
    XCTAssertNil(collectionFromDocument.limit)
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
