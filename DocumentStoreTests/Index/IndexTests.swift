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

  // TODO: Should move to storageInformation tests
  func testValid() {
    let index = AnyIndex(from: Index<TestDocument, Bool>(name: "TestIndex", resolver: { _ in false }))
    XCTAssertTrue(UntypedAnyStorageInformation(storageInformation: index.storageInformation).validate().isEmpty)
  }

  func testEmptyIdentifier() {
    let index = AnyIndex(from: Index<TestDocument, Bool>(name: "", resolver: { _ in false }))
    XCTAssertEqual(UntypedAnyStorageInformation(storageInformation: index.storageInformation).validate(), ["Name may not be empty."])
  }

  func testUnderscoreIdentifier() {
    for identifier in ["_", "_Index"] {
      let index = AnyIndex(from: Index<TestDocument, Bool>(name: identifier, resolver: { _ in false }))
      XCTAssertEqual(UntypedAnyStorageInformation(storageInformation: index.storageInformation).validate(), ["`\(identifier)` is an invalid name, names may not start with an `_`."])
    }
  }

  func testEquatable() {
    let boolStorageInfo = StorageInformation<TestDocument, Bool>(propertyName: .userDefined("TestIndex"))
    let untypedBoolStorageInfo = UntypedAnyStorageInformation(storageInformation: AnyStorageInformation(storageInformation: boolStorageInfo))
    XCTAssertEqual(untypedBoolStorageInfo, untypedBoolStorageInfo)

    let stringStorageInfo = StorageInformation<TestDocument, String>(propertyName: .userDefined("TestIndex"))
    let untypedStringStorageInfo = UntypedAnyStorageInformation(storageInformation: AnyStorageInformation(storageInformation: stringStorageInfo))
    XCTAssertNotEqual(untypedBoolStorageInfo, untypedStringStorageInfo)

    let otherStringStorageInfo = StorageInformation<TestDocument, String>(propertyName: .userDefined("OtherTestIndex"))
    let untypedOtherStringStorageInfo = UntypedAnyStorageInformation(storageInformation: AnyStorageInformation(storageInformation: otherStringStorageInfo))
    XCTAssertNotEqual(untypedStringStorageInfo, untypedOtherStringStorageInfo)

    let otherDocumentStorageInfo = StorageInformation<OtherTestDocument, String>(propertyName: .userDefined("TestIndex"))
    let untypedOtherDocumentStorageInfo = UntypedAnyStorageInformation(storageInformation: AnyStorageInformation(storageInformation: otherDocumentStorageInfo))
    XCTAssertNotEqual(untypedStringStorageInfo, untypedOtherDocumentStorageInfo)
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
