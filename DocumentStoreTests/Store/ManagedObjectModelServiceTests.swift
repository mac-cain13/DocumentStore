//
//  ManagedObjectModelServiceTests.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 16-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import XCTest
@testable import DocumentStore
import CoreData

class ManagedObjectModelServiceTests: XCTestCase {

  let managedObjectModelService =  ManagedObjectModelServiceImpl()

  // MARK: Validate

  func testValidateEmpty() {
    do {
      let descriptors: [AnyDocumentDescriptor] = []
      let validated = try managedObjectModelService.validate(descriptors, logTo: NoLogger())
      XCTAssertEqual(validated.documentDescriptors, descriptors)
    } catch {
      XCTFail("Expected no error")
    }
  }

  func testValidateValid() {
    do {
      let descriptors = [TestDocument.documentDescriptor.eraseType()]
      let validated = try managedObjectModelService.validate(descriptors, logTo: NoLogger())
      XCTAssertEqual(validated.documentDescriptors, descriptors)
    } catch {
      XCTFail("Expected no error")
    }
  }

  func testValidateBubblesDescriptorErrors() {
    let invalidDescriptor = DocumentDescriptor<TestDocument>(name: "_", indices: []).eraseType()
    let issues = invalidDescriptor.validate()
    XCTAssertFalse(issues.isEmpty, "Invalid descriptor does not seem to be invalid")

    do {
      let _ = try managedObjectModelService.validate([invalidDescriptor], logTo: NoLogger())
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
    let issues = ["Multiple DocumentDescriptors have `\(TestDocument.documentDescriptor.name)` as name, every document descriptor must have an unique name."]

    do {
      let descriptors = [TestDocument.documentDescriptor.eraseType(), TestDocument.documentDescriptor.eraseType()]
      let validated = try managedObjectModelService.validate(descriptors, logTo: NoLogger())
      XCTAssertEqual(validated.documentDescriptors, descriptors)
    } catch let error as DocumentStoreError {
      XCTAssertEqual(error.kind, DocumentStoreError.ErrorKind.documentDescriptionInvalid)
      XCTAssertNil(error.underlyingError)
      XCTAssertEqual(error.message, errorMessage(with: issues))
    } catch {
      XCTFail("Unexpected error type")
    }
  }

  func testValidateLogging() {
    let invalidDescriptor = DocumentDescriptor<TestDocument>(name: "_", indices: []).eraseType()
    let issues = invalidDescriptor.validate()
    XCTAssertFalse(issues.isEmpty, "Invalid descriptor does not seem to be invalid")

    let logger = MockLogger()

    do {
      let _ = try managedObjectModelService.validate([invalidDescriptor], logTo: logger)
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
    let descriptors = ValidatedDocumentDescriptors(documentDescriptors: [])
    let model = managedObjectModelService.generateModel(from: descriptors, logTo: NoLogger())
    XCTAssertTrue(model.entities.isEmpty)
  }

  func testModelDocumentDataProperty() {
    let descriptors = ValidatedDocumentDescriptors(documentDescriptors: [TestDocument.documentDescriptor.eraseType()])
    let model = managedObjectModelService.generateModel(from: descriptors, logTo: NoLogger())
    XCTAssertEqual(model.entities.count, 1)

    let entity = model.entities.first
    XCTAssertEqual(entity?.name, TestDocument.documentDescriptor.name)
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
    let index = Index<TestDocument, Bool>(name: "TestIndex", resolver: { _ in false }).eraseType()
    let documentDescriptor = DocumentDescriptor<TestDocument>(name: "TestDocument", indices: [index])

    let descriptors = ValidatedDocumentDescriptors(documentDescriptors: [documentDescriptor.eraseType()])
    let model = managedObjectModelService.generateModel(from: descriptors, logTo: NoLogger())
    XCTAssertEqual(model.entities.count, 1)

    let entity = model.entities.first
    XCTAssertEqual(entity?.name, documentDescriptor.name)
    XCTAssertEqual(entity?.properties.count, 2)
    XCTAssertNotNil(entity?.propertiesByName[DocumentDataAttributeName])

    XCTAssertEqual(entity?.propertiesByName.count, documentDescriptor.indices.count + 1)

    let property = entity?.propertiesByName[index.storageInformation.propertyName.keyPath] as? NSAttributeDescription
    XCTAssertNotNil(property)
    XCTAssertEqual(property?.name, index.storageInformation.propertyName.keyPath)
    XCTAssertEqual(property?.attributeType, index.storageInformation.storageType.attributeType)
    XCTAssertEqual(property?.isIndexed, true)
    XCTAssertEqual(property?.isOptional, false)
  }

  func testModelLogging() {
    let index = Index<TestDocument, Bool>(name: "TestIndex", resolver: { _ in false }).eraseType()
    let documentDescriptor = DocumentDescriptor<TestDocument>(name: "TestDocument", indices: [index])

    let descriptors = ValidatedDocumentDescriptors(documentDescriptors: [documentDescriptor.eraseType()])
    let logger = MockLogger()
    _ = managedObjectModelService.generateModel(from: descriptors, logTo: logger)

    let expectedLogs: [MockLogger.LogMessage] = [
      MockLogger.LogMessage(level: .trace, message: "Creating shared attribute `_documentData`..."),
      MockLogger.LogMessage(level: .trace, message: "Creating entity `\(documentDescriptor.name)`..."),
      MockLogger.LogMessage(level: .trace, message: "  Creating attribute `\(index.storageInformation.propertyName.keyPath)` of type \(index.storageInformation.storageType.attributeType)...")
    ]

    XCTAssertEqual(logger.loggedMessages, expectedLogs)
  }
}

private func errorMessage(with issues: [ValidationIssue]) -> String {
  return "One or more document descriptors are invalid:\n - " + issues.joined(separator: "\n - ")
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
