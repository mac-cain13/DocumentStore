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
    let issues = DocumentDescriptor<TestDocument>(name: "TestDocument", indices: []).eraseType().validate()

    XCTAssertTrue(issues.isEmpty)
  }

  func testEmptyIdentifier() {
    let issues = DocumentDescriptor<TestDocument>(name: "", indices: []).eraseType().validate()

    XCTAssertEqual(issues.count, 1)
    XCTAssertEqual(issues.first, "DocumentDescriptor names may not be empty.")
  }

  func testUnderscoreIdentifier() {
    for identifier in ["_", "_Something"] {
      let issues = DocumentDescriptor<TestDocument>(name: identifier, indices: []).eraseType().validate()

      XCTAssertEqual(issues.count, 1)
      XCTAssertEqual(
        issues.first,
        "`\(identifier)` is an invalid DocumentDescriptor name, names may not start with an `_`."
      )
    }
  }

  func testDuplicateIndexIdentifiers() {
    let name = "TestDocument"
    let duplicateIndex = "DuplicateIndex"
    let indices = [
      Index<TestDocument, Bool>(name: duplicateIndex, resolver: { _ in false }).eraseType(),
      Index<TestDocument, Int>(name: "OtherIndex", resolver: { _ in 0 }).eraseType(),
      Index<TestDocument, String>(name: duplicateIndex, resolver: { _ in "" }).eraseType(),
    ]
    let issues = DocumentDescriptor<TestDocument>(name: name, indices: indices).eraseType().validate()

    XCTAssertEqual(issues.count, 1)
    XCTAssertEqual(
      issues.first,
      "DocumentDescriptor `\(name)` has multiple indices with `\(duplicateIndex)` as name, every index name must be unique."
    )
  }

  func testInvalidIndex() {
    let invalidIndex = Index<TestDocument, Bool>(name: "_", resolver: { _ in false }).eraseType()
    let indexIssues = UntypedAnyStorageInformation(storageInformation: invalidIndex.storageInformation).validate()

    let issues = DocumentDescriptor<TestDocument>(name: "TestDocument", indices: [invalidIndex]).eraseType().validate()

    XCTAssertEqual(issues.count, indexIssues.count)
    XCTAssertEqual(issues, indexIssues)
  }

  func testMultipleIssues() {
    let invalidIndex = Index<TestDocument, Bool>(name: "_", resolver: { _ in false }).eraseType()
    let indexIssues = UntypedAnyStorageInformation(storageInformation: invalidIndex.storageInformation).validate()

    let name = "_"
    let duplicateIndex = "DuplicateIndex"
    let indices = [
      Index<TestDocument, Bool>(name: duplicateIndex, resolver: { _ in false }).eraseType(),
      invalidIndex,
      Index<TestDocument, String>(name: duplicateIndex, resolver: { _ in "" }).eraseType(),
      ]
    let issues = DocumentDescriptor<TestDocument>(name: name, indices: indices).eraseType().validate()

    XCTAssertEqual(issues.count, 3)
    XCTAssertEqual(
      issues,
      [
        "`\(name)` is an invalid DocumentDescriptor name, names may not start with an `_`.",
        "DocumentDescriptor `\(name)` has multiple indices with `\(duplicateIndex)` as name, every index name must be unique."
      ] + indexIssues
    )
  }

  func testEquatable() {
    let descriptor = DocumentDescriptor<TestDocument>(name: "TestDocument", indices: []).eraseType()
    XCTAssertEqual(descriptor, descriptor)

    // Note; The DocumentType in de descriptor is just to validate the indices are for this document, it cannot be checked in the equasion
    let otherDocumentDescriptor = DocumentDescriptor<OtherTestDocument>(name: "TestDocument", indices: []).eraseType()
    XCTAssertEqual(descriptor, otherDocumentDescriptor)

    let otherIdentifierDescriptor = DocumentDescriptor<TestDocument>(name: "OtherTestDocument", indices: []).eraseType()
    XCTAssertNotEqual(descriptor, otherIdentifierDescriptor)

    let index = Index<TestDocument, Bool>(name: "") { _ in false }.eraseType()
    let otherIndexDescriptor = DocumentDescriptor<TestDocument>(name: "TestDocument", indices: [index]).eraseType()
    XCTAssertNotEqual(descriptor, otherIndexDescriptor)
  }
}

private struct TestDocument: Document {
  static var documentDescriptor = DocumentDescriptor<TestDocument>(name: "TestDocument", indices: [])

  func serializeDocument() throws -> Data {
    return Data()
  }

  static func deserializeDocument(from data: Data) throws -> TestDocument {
    return TestDocument()
  }
}

private struct OtherTestDocument: Document {
  static var documentDescriptor = DocumentDescriptor<OtherTestDocument>(name: "OtherTestDocument", indices: [])

  func serializeDocument() throws -> Data {
    return Data()
  }

  static func deserializeDocument(from data: Data) throws -> OtherTestDocument {
    return OtherTestDocument()
  }
}
