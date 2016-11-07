//
//  DocumentDescriptor+UtilTests.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 07-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import XCTest
@testable import DocumentStore
import CoreData

class DocumentDescriptorUtilTests: XCTestCase {

  private func errorMessage(with issues: [ValidationIssue]) -> String {
    return "One or more document descriptors are invalid:\n - " + issues.joined(separator: "\n - ")
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

  // MARK: Validate

  func testValidateEmpty() {
    do {
      try validate([], logTo: NoLogger())
    } catch {
      XCTFail("Expected no error")
    }
  }

  func testValidateValid() {
    do {
      try validate([TestDocument.documentDescriptor.eraseType()], logTo: NoLogger())
    } catch {
      XCTFail("Expected no error")
    }
  }

  func testValidateBubblesDescriptorErrors() {
    let invalidDescriptor = DocumentDescriptor<TestDocument>(identifier: "_", indices: []).eraseType()
    let issues = invalidDescriptor.validate()
    XCTAssertFalse(issues.isEmpty, "Invalid descriptor does not seem to be invalid")

    do {
      try validate([invalidDescriptor], logTo: NoLogger())
      XCTFail("Error was expected")
    } catch let error as DocumentStoreError {
      XCTAssertEqual(error.kind, DocumentStoreError.ErrorKind.documentDescriptionInvalid)
      XCTAssertNil(error.underlyingError)
      XCTAssertEqual(error.message, errorMessage(with: issues))
    } catch {
      XCTFail("Unexpected error type")
    }
  }

  func testValidateDuplicateDescriptorIdentifiers() {
    let issues = ["Multiple DocumentDescriptors have `\(TestDocument.documentDescriptor.identifier)` as identifier, every document descriptor must have an unique identifier."]

    do {
      try validate([TestDocument.documentDescriptor.eraseType(), TestDocument.documentDescriptor.eraseType()], logTo: NoLogger())
    } catch let error as DocumentStoreError {
      XCTAssertEqual(error.kind, DocumentStoreError.ErrorKind.documentDescriptionInvalid)
      XCTAssertNil(error.underlyingError)
      XCTAssertEqual(error.message, errorMessage(with: issues))
    } catch {
      XCTFail("Unexpected error type")
    }
  }

  func testValidateLogging() {
    let invalidDescriptor = DocumentDescriptor<TestDocument>(identifier: "_", indices: []).eraseType()
    let issues = invalidDescriptor.validate()
    XCTAssertFalse(issues.isEmpty, "Invalid descriptor does not seem to be invalid")

    let logger = MockLogger()

    do {
      try validate([invalidDescriptor], logTo: logger)
      XCTFail("Error was expected")
    } catch let error as DocumentStoreError {
      XCTAssertEqual(logger.loggedMessages.count, 1)
      XCTAssertEqual(logger.loggedMessages.first?.level, LogLevel.warn)
      XCTAssertEqual(logger.loggedMessages.first?.message, error.message)
    } catch {
      XCTFail("Unexpected error type")
    }
  }

  // MARK: ManagedObjectModel

  func testModelEmpty() {
    let model = managedObjectModel(from: [], logTo: NoLogger())
    XCTAssertTrue(model.entities.isEmpty)
  }

  func testModelDocumentDataProperty() {
    let model = managedObjectModel(from: [TestDocument.documentDescriptor.eraseType()], logTo: NoLogger())
    XCTAssertEqual(model.entities.count, 1)

    let entity = model.entities.first
    XCTAssertEqual(entity?.name, TestDocument.documentDescriptor.identifier)
    XCTAssertEqual(entity?.properties.count, 1)

    let property = entity?.properties.first as? NSAttributeDescription
    XCTAssertNotNil(property)
    XCTAssertEqual(property?.name, DocumentDataAttributeName)
    XCTAssertEqual(property?.attributeType, NSAttributeType.binaryDataAttributeType)
    XCTAssertEqual(property?.isIndexed, false)
    XCTAssertEqual(property?.isOptional, false)
    XCTAssertEqual(property?.allowsExternalBinaryDataStorage, true)
  }

  func testModelIndexProperty() {
    let index = Index<TestDocument, Bool>(identifier: "TestIndex", resolver: { _ in false }).eraseType()
    let documentDescriptor = DocumentDescriptor<TestDocument>(identifier: "TestDocument", indices: [index])

    let model = managedObjectModel(from: [documentDescriptor.eraseType()], logTo: NoLogger())
    XCTAssertEqual(model.entities.count, 1)

    let entity = model.entities.first
    XCTAssertEqual(entity?.name, documentDescriptor.identifier)
    XCTAssertEqual(entity?.properties.count, 2)
    XCTAssertNotNil(entity?.propertiesByName[DocumentDataAttributeName])

    let property = entity?.propertiesByName[index.identifier] as? NSAttributeDescription
    XCTAssertNotNil(property)
    XCTAssertEqual(property?.name, index.identifier)
    XCTAssertEqual(property?.attributeType, index.storageType.attributeType)
    XCTAssertEqual(property?.isIndexed, true)
    XCTAssertEqual(property?.isOptional, false)
  }

  func testModelLogging() {
    let index = Index<TestDocument, Bool>(identifier: "TestIndex", resolver: { _ in false }).eraseType()
    let documentDescriptor = DocumentDescriptor<TestDocument>(identifier: "TestDocument", indices: [index])

    let logger = MockLogger()
    _ = managedObjectModel(from: [documentDescriptor.eraseType()], logTo: logger)

    let expectedLogs: [MockLogger.LogMessage] = [
      MockLogger.LogMessage(level: .trace, message: "Creating shared attribute `_DocumentData`..."),
      MockLogger.LogMessage(level: .trace, message: "Creating entity `\(documentDescriptor.identifier)`..."),
      MockLogger.LogMessage(level: .trace, message: "  Creating attribute `\(index.identifier)` of type \(index.storageType.attributeType)...")
    ]

    XCTAssertEqual(logger.loggedMessages, expectedLogs)
  }
}
