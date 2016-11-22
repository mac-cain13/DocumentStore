//
//  SortDescriptorTests.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 13-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import XCTest
@testable import DocumentStore

class SortDescriptorTests: XCTestCase {

  func testInitializer() {
    let nsSortDescriptor = NSSortDescriptor(key: "Test", ascending: false)
    let sortDescriptor = SortDescriptor<TestDocument>(sortDescriptor: nsSortDescriptor)
    XCTAssertEqual(sortDescriptor.sortDescriptor, nsSortDescriptor)
  }

  // MARK: Index sortdescriptors

  func testAscending() {
    let nsSortDescriptor = NSSortDescriptor(key: TestDocument.isTest.identifier, ascending: true)
    XCTAssertEqual(TestDocument.isTest.ascending().sortDescriptor, nsSortDescriptor)
  }

  func testDescending() {
    let nsSortDescriptor = NSSortDescriptor(key: TestDocument.isTest.identifier, ascending: false)
    XCTAssertEqual(TestDocument.isTest.descending().sortDescriptor, nsSortDescriptor)
  }
}

private struct TestDocument: Document {
  static let isTest = Index<TestDocument, Bool>(identifier: "") { _ in false }
  static let documentDescriptor = DocumentDescriptor<TestDocument>(identifier: "", indices: [])

  func serializeDocument() throws -> Data {
    return Data()
  }

  static func deserializeDocument(from data: Data) throws -> TestDocument {
    return TestDocument()
  }
}
