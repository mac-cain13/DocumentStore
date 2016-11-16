//
//  IndexTests.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 07-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import XCTest
@testable import DocumentStore

class IndexTests: XCTestCase {

  func testValid() {
    let index = Index<TestDocument, Bool>(identifier: "TestIndex", resolver: { _ in false }).eraseType()
    XCTAssertTrue(UntypedAnyIndex(index: index).validate().isEmpty)
  }

  func testEmptyIdentifier() {
    let index = Index<TestDocument, Bool>(identifier: "", resolver: { _ in false }).eraseType()
    XCTAssertEqual(UntypedAnyIndex(index: index).validate(), ["Index identifiers may not be empty."])
  }

  func testUnderscoreIdentifier() {
    for identifier in ["_", "_Index"] {
      let index = Index<TestDocument, Bool>(identifier: identifier, resolver: { _ in false }).eraseType()
      XCTAssertEqual(UntypedAnyIndex(index: index).validate(), ["`\(identifier)` is an invalid Index identifier, identifiers may not start with an `_`."])
    }
  }

  func testEquatable() {
    let boolIndex = Index<TestDocument, Bool>(identifier: "TestIndex", resolver: { _ in false }).eraseType()
    XCTAssertEqual(UntypedAnyIndex(index: boolIndex), UntypedAnyIndex(index: boolIndex))

    let stringIndex = Index<TestDocument, String>(identifier: "TestIndex", resolver: { _ in "" }).eraseType()
    XCTAssertNotEqual(UntypedAnyIndex(index: boolIndex), UntypedAnyIndex(index: stringIndex))

    let otherStringIndex = Index<TestDocument, String>(identifier: "OtherTestIndex", resolver: { _ in "" }).eraseType()
    XCTAssertNotEqual(UntypedAnyIndex(index: stringIndex), UntypedAnyIndex(index: otherStringIndex))

    let otherDocumentIndex = Index<OtherTestDocument, String>(identifier: "TestIndex", resolver: { _ in "" }).eraseType()
    XCTAssertNotEqual(UntypedAnyIndex(index: stringIndex), UntypedAnyIndex(index: otherDocumentIndex))
  }
}

private struct TestDocument: Document {
  static var documentDescriptor = DocumentDescriptor<TestDocument>(identifier: "TestDocument", indices: [])

  func serializeDocument() throws -> Data {
    return Data()
  }

  static func deserializeDocument(from data: Data) throws -> TestDocument {
    return TestDocument()
  }
}

private struct OtherTestDocument: Document {
  static var documentDescriptor = DocumentDescriptor<OtherTestDocument>(identifier: "OtherTestDocument", indices: [])

  func serializeDocument() throws -> Data {
    return Data()
  }

  static func deserializeDocument(from data: Data) throws -> OtherTestDocument {
    return OtherTestDocument()
  }
}
