//
//  DocumentDescriptorTests.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 07-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import XCTest
@testable import DocumentStore

class DocumentDescriptorTests: XCTestCase {

  func testValidDescriptor() {
    let issues = DocumentDescriptor<TestDocument>(identifier: "TestDocument", indices: []).eraseType().validate()

    XCTAssertTrue(issues.isEmpty)
  }

  func testEmptyIdentifier() {
    let issues = DocumentDescriptor<TestDocument>(identifier: "", indices: []).eraseType().validate()

    XCTAssertEqual(issues.count, 1)
    XCTAssertEqual(issues.first, "DocumentDescriptor identifiers may not be empty.")
  }

  func testUnderscoreIdentifier() {
    for identifier in ["_", "_Something"] {
      let issues = DocumentDescriptor<TestDocument>(identifier: identifier, indices: []).eraseType().validate()

      XCTAssertEqual(issues.count, 1)
      XCTAssertEqual(
        issues.first,
        "`\(identifier)` is an invalid DocumentDescriptor identifier, identifiers may not start with an `_`."
      )
    }
  }

  func testDuplicateIndexIdentifiers() {
    let identifier = "TestDocument"
    let duplicateIndex = "DuplicateIndex"
    let indices = [
      Index<TestDocument, Bool>(identifier: duplicateIndex, resolver: { _ in false }).eraseType(),
      Index<TestDocument, Int>(identifier: "OtherIndex", resolver: { _ in 0 }).eraseType(),
      Index<TestDocument, String>(identifier: duplicateIndex, resolver: { _ in "" }).eraseType(),
    ]
    let issues = DocumentDescriptor<TestDocument>(identifier: identifier, indices: indices).eraseType().validate()

    XCTAssertEqual(issues.count, 1)
    XCTAssertEqual(
      issues.first,
      "DocumentDescriptor `\(identifier)` has multiple indices with `\(duplicateIndex)` as identifier, every index identifier must be unique."
    )
  }

  func testInvalidIndex() {
    let invalidIndex = Index<TestDocument, Bool>(identifier: "_", resolver: { _ in false }).eraseType()
    let indexIssues = UntypedAnyIndex(index: invalidIndex).validate()
    XCTAssertFalse(indexIssues.isEmpty, "Invalid index does not seem to be invalid")

    let issues = DocumentDescriptor<TestDocument>(identifier: "TestDocument", indices: [invalidIndex]).eraseType().validate()

    XCTAssertEqual(issues.count, indexIssues.count)
    XCTAssertEqual(issues, indexIssues)
  }

  func testMultipleIssues() {
    let invalidIndex = Index<TestDocument, Bool>(identifier: "_", resolver: { _ in false }).eraseType()
    let indexIssues = UntypedAnyIndex(index: invalidIndex).validate()
    XCTAssertFalse(indexIssues.isEmpty, "Invalid index does not seem to be invalid")

    let identifier = "_"
    let duplicateIndex = "DuplicateIndex"
    let indices = [
      Index<TestDocument, Bool>(identifier: duplicateIndex, resolver: { _ in false }).eraseType(),
      invalidIndex,
      Index<TestDocument, String>(identifier: duplicateIndex, resolver: { _ in "" }).eraseType(),
      ]
    let issues = DocumentDescriptor<TestDocument>(identifier: identifier, indices: indices).eraseType().validate()

    XCTAssertEqual(issues.count, 3)
    XCTAssertEqual(
      issues,
      [
        "`\(identifier)` is an invalid DocumentDescriptor identifier, identifiers may not start with an `_`.",
        "DocumentDescriptor `\(identifier)` has multiple indices with `\(duplicateIndex)` as identifier, every index identifier must be unique."
      ] + indexIssues
    )
  }

  func testEquatable() {
    let descriptor = DocumentDescriptor<TestDocument>(identifier: "TestDocument", indices: []).eraseType()
    XCTAssertEqual(descriptor, descriptor)

    // Note; The DocumentType in de descriptor is just to validate the indices are for this document, it cannot be checked in the equasion
    let otherDocumentDescriptor = DocumentDescriptor<OtherTestDocument>(identifier: "TestDocument", indices: []).eraseType()
    XCTAssertEqual(descriptor, otherDocumentDescriptor)

    let otherIdentifierDescriptor = DocumentDescriptor<TestDocument>(identifier: "OtherTestDocument", indices: []).eraseType()
    XCTAssertNotEqual(descriptor, otherIdentifierDescriptor)

    let index = Index<TestDocument, Bool>(identifier: "") { _ in false }.eraseType()
    let otherIndexDescriptor = DocumentDescriptor<TestDocument>(identifier: "TestDocument", indices: [index]).eraseType()
    XCTAssertNotEqual(descriptor, otherIndexDescriptor)
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
