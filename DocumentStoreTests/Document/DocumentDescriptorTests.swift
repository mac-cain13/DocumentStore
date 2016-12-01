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
    let issues = AnyDocumentDescriptor(from: DocumentDescriptor<TestDocument>(name: "TestDocument", identifier: Identifier { _ in return UUID().uuidString }, indices: [])).validate()

    XCTAssertTrue(issues.isEmpty)
  }

  func testEmptyIdentifier() {
    let issues = AnyDocumentDescriptor(from: DocumentDescriptor<TestDocument>(name: "", identifier: Identifier { _ in return UUID().uuidString }, indices: [])).validate()

    XCTAssertEqual(issues.count, 1)
    XCTAssertEqual(issues.first, "DocumentDescriptor names may not be empty.")
  }

  func testUnderscoreIdentifier() {
    for identifier in ["_", "_Something"] {
      let issues = AnyDocumentDescriptor(from: DocumentDescriptor<TestDocument>(name: identifier, identifier: Identifier { _ in return UUID().uuidString }, indices: [])).validate()

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
    let indices = IndexArrayBuilder()
      .append(Index<TestDocument, Bool>(name: duplicateIndex, resolver: { _ in false }))
      .append(Index<TestDocument, Int>(name: "OtherIndex", resolver: { _ in 0 }))
      .append(Index<TestDocument, String>(name: duplicateIndex, resolver: { _ in "" }))
      .array
    let issues = AnyDocumentDescriptor(from: DocumentDescriptor<TestDocument>(name: name, identifier: Identifier { _ in return UUID().uuidString }, indices: indices)).validate()

    XCTAssertEqual(issues.count, 1)
    XCTAssertEqual(
      issues.first,
      "DocumentDescriptor `\(name)` has multiple indices with `\(duplicateIndex)` as name, every index name must be unique."
    )
  }

  func testInvalidIndex() {
    let invalidIndex = AnyIndex(from: Index<TestDocument, Bool>(name: "_", resolver: { _ in false }))
    let indexIssues = UntypedAnyStorageInformation(from: invalidIndex.storageInformation).validate()

    let issues = AnyDocumentDescriptor(from: DocumentDescriptor<TestDocument>(name: "TestDocument", identifier: Identifier { _ in return UUID().uuidString }, indices: [invalidIndex])).validate()

    XCTAssertEqual(issues.count, indexIssues.count)
    XCTAssertEqual(issues, indexIssues)
  }

  func testMultipleIssues() {
    let invalidIndex = Index<TestDocument, Bool>(name: "_", resolver: { _ in false })
    let indexIssues = UntypedAnyStorageInformation(from: AnyIndex(from: invalidIndex).storageInformation).validate()

    let name = "_"
    let duplicateIndex = "DuplicateIndex"
    let indices = IndexArrayBuilder()
      .append(Index<TestDocument, Bool>(name: duplicateIndex, resolver: { _ in false }))
      .append(invalidIndex)
      .append(Index<TestDocument, String>(name: duplicateIndex, resolver: { _ in "" }))
      .array
    let issues = AnyDocumentDescriptor(from: DocumentDescriptor<TestDocument>(name: name, identifier: Identifier { _ in return UUID().uuidString }, indices: indices)).validate()

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
    let descriptor = AnyDocumentDescriptor(from: DocumentDescriptor<TestDocument>(name: "TestDocument", identifier: Identifier { _ in return UUID().uuidString }, indices: []))
    XCTAssertEqual(descriptor, descriptor)

    // Note; The DocumentType in de descriptor is just to validate the indices are for this document, it cannot be checked in the equasion
    let otherDocumentDescriptor = AnyDocumentDescriptor(from: DocumentDescriptor<OtherTestDocument>(name: "TestDocument", identifier: Identifier { _ in return UUID().uuidString }, indices: []))
    XCTAssertEqual(descriptor, otherDocumentDescriptor)

    let otherIdentifierDescriptor = AnyDocumentDescriptor(from: DocumentDescriptor<TestDocument>(name: "OtherTestDocument", identifier: Identifier { _ in return UUID().uuidString }, indices: []))
    XCTAssertNotEqual(descriptor, otherIdentifierDescriptor)

    let index = AnyIndex(from: Index<TestDocument, Bool>(name: "") { _ in false })
    let otherIndexDescriptor = AnyDocumentDescriptor(from: DocumentDescriptor<TestDocument>(name: "TestDocument", identifier: Identifier { _ in return UUID().uuidString }, indices: [index]))
    XCTAssertNotEqual(descriptor, otherIndexDescriptor)
  }
}

private struct TestDocument: Document {
  static var documentDescriptor = DocumentDescriptor<TestDocument>(name: "TestDocument", identifier: Identifier { _ in return UUID().uuidString }, indices: [])

  func serializeDocument() throws -> Data {
    return Data()
  }

  static func deserializeDocument(from data: Data) throws -> TestDocument {
    return TestDocument()
  }
}

private struct OtherTestDocument: Document {
  static var documentDescriptor = DocumentDescriptor<OtherTestDocument>(name: "OtherTestDocument", identifier: Identifier { _ in return UUID().uuidString }, indices: [])

  func serializeDocument() throws -> Data {
    return Data()
  }

  static func deserializeDocument(from data: Data) throws -> OtherTestDocument {
    return OtherTestDocument()
  }
}
