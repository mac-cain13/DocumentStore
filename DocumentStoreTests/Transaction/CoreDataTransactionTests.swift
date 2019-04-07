//
//  CoreDataTransactionTests.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 14-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import XCTest
@testable import DocumentStore
import CoreData

class CoreDataTransactionTests: XCTestCase {

  let model = NSManagedObjectModel()

  var container: NSPersistentContainer!
  var context: NSManagedObjectContext!
  var logger = MockLogger()

  var transaction: CoreDataTransaction!

  override func setUp() {
    super.setUp()
    TestDocument.deserializationResult = .succeeds

    let property = NSAttributeDescription()
    property.name = DocumentDataAttributeName
    property.attributeType = .binaryDataAttributeType
    property.isOptional = true

    let indexProperty = NSAttributeDescription()
    indexProperty.name = TestDocument.isTest.storageInformation.propertyName.keyPath
    indexProperty.attributeType = .booleanAttributeType

    let entity = NSEntityDescription()
    entity.name = TestDocument.documentDescriptor.name
    entity.properties = [property, indexProperty]
    model.entities = [entity]

    container = NSPersistentContainer(name: UUID().uuidString, managedObjectModel: model)
    container.loadPersistentStores { (_, error) in
      if let error = error { fatalError(error.localizedDescription) }
    }
    context = container.newBackgroundContext()
    logger = MockLogger()

    transaction = CoreDataTransaction(context: context, documentDescriptors: ValidatedDocumentDescriptors(documentDescriptors: [TestDocument.documentDescriptor]), logTo: logger)
  }

  // MARK: Unregistered document type

  func testCountWithUnregisteredDocumentType() {
    let transaction = CoreDataTransaction(context: context, documentDescriptors: ValidatedDocumentDescriptors(documentDescriptors: []), logTo: logger)

    let query = Query<TestDocument>()
    do {
      _ = try transaction.count(matching: query)
      XCTFail("Expected error")
    } catch let error as TransactionError {
      guard case let .documentStoreError(documentStoreError) = error else {
        XCTFail("Expected DocumentStoreError")
        return
      }

      XCTAssertEqual(documentStoreError.kind, .documentDescriptionNotRegistered)
      XCTAssertNil(documentStoreError.underlyingError)
    } catch {
      XCTFail("Expected TransactionError")
    }
  }

  func testFetchWithUnregisteredDocumentType() {
    let transaction = CoreDataTransaction(context: context, documentDescriptors: ValidatedDocumentDescriptors(documentDescriptors: []), logTo: logger)

    let query = Query<TestDocument>()
    do {
      _ = try transaction.fetch(matching: query)
      XCTFail("Expected error")
    } catch let error as TransactionError {
      guard case let .documentStoreError(documentStoreError) = error else {
        XCTFail("Expected DocumentStoreError")
        return
      }

      XCTAssertEqual(documentStoreError.kind, .documentDescriptionNotRegistered)
      XCTAssertNil(documentStoreError.underlyingError)
    } catch {
      XCTFail("Expected TransactionError")
    }
  }

  func testDeletetWithUnregisteredDocumentType() {
    let transaction = CoreDataTransaction(context: context, documentDescriptors: ValidatedDocumentDescriptors(documentDescriptors: []), logTo: logger)

    let query = Query<TestDocument>()
    do {
      _ = try transaction.delete(matching: query)
      XCTFail("Expected error")
    } catch let error as TransactionError {
      guard case let .documentStoreError(documentStoreError) = error else {
        XCTFail("Expected DocumentStoreError")
        return
      }

      XCTAssertEqual(documentStoreError.kind, .documentDescriptionNotRegistered)
      XCTAssertNil(documentStoreError.underlyingError)
    } catch {
      XCTFail("Expected TransactionError")
    }
  }

  // TODO: Write save test
//  func testAddWithUnregisteredDocumentType() {
//    let transaction = CoreDataTransaction(context: context, documentDescriptors: ValidatedDocumentDescriptors(documentDescriptors: []), logTo: logger)
//
//    let document = TestDocument()
//    do {
//      _ = try transaction.add(document: document)
//      XCTFail("Expected error")
//    } catch let error as TransactionError {
//      guard case let .documentStoreError(documentStoreError) = error else {
//        XCTFail("Expected DocumentStoreError")
//        return
//      }
//
//      XCTAssertEqual(documentStoreError.kind, .documentDescriptionNotRegistered)
//      XCTAssertNil(documentStoreError.underlyingError)
//    } catch {
//      XCTFail("Expected TransactionError")
//    }
//  }

  // MARK: Happy flow tests

  func testCount() {
    let entity = NSEntityDescription.insertNewObject(forEntityName: TestDocument.documentDescriptor.name, into: context)
    entity.setValue(Data(), forKey: DocumentDataAttributeName)
    entity.setValue(false, forKey: TestDocument.isTest.storageInformation.propertyName.keyPath)

    do {
      let count = try transaction.count(matching: Query<TestDocument>())
      XCTAssertEqual(count, 1)
    } catch {
      XCTFail("Unexpected error")
    }
  }

  func testFetch() {
    let entity = NSEntityDescription.insertNewObject(forEntityName: TestDocument.documentDescriptor.name, into: context)
    entity.setValue(Data(), forKey: DocumentDataAttributeName)
    entity.setValue(false, forKey: TestDocument.isTest.storageInformation.propertyName.keyPath)

    do {
      let items = try transaction.fetch(matching: Query<TestDocument>())
      XCTAssertEqual(items.count, 1)
    } catch {
      XCTFail("Unexpected error")
    }
  }

  func testDelete() {
    NSEntityDescription.insertNewObject(forEntityName: TestDocument.documentDescriptor.name, into: context)

    do {
      let deletions = try transaction.delete(matching: Query<TestDocument>())
      XCTAssertEqual(deletions, 1)
      XCTAssertEqual(context.deletedObjects.count, 1)
    } catch {
      XCTFail("Unexpected error")
    }
  }

  // TODO: Write save test
//  func testAdd() {
//    let document = TestDocument()
//    XCTAssertFalse(context.hasChanges)
//
//    do {
//      try transaction.add(document: document)
//      XCTAssertTrue(context.hasChanges)
//      XCTAssertEqual(context.insertedObjects.count, 1)
//
//      guard let data = context.insertedObjects.first?.value(forKey: DocumentDataAttributeName) as? Data else {
//        XCTFail("No data for inserted object")
//        return
//      }
//      XCTAssertEqual(data, TestDocument.data)
//
//      guard let bool = context.insertedObjects.first?.value(forKey: TestDocument.isTest.storageInformation.propertyName.keyPath) as? Bool else {
//        XCTFail("No index for inserted object")
//        return
//      }
//      XCTAssertEqual(bool, TestDocument.isTest.resolver(document))
//    } catch {
//      XCTFail("Unexpected error")
//    }
//  }

  func testPersistChanges() {
    let transaction = CoreDataTransaction(context: context, documentDescriptors: ValidatedDocumentDescriptors(documentDescriptors: []), logTo: logger)

    NSEntityDescription.insertNewObject(forEntityName: TestDocument.documentDescriptor.name, into: context)
    XCTAssertTrue(context.hasChanges)
    do {
      try transaction.persistChanges()
      XCTAssertFalse(context.hasChanges)
    } catch {
      XCTFail("Unexpected error")
    }
  }

  // MARK: Unhappy flow tests

  func testFetchUndeserializableDocumentWithOtherError() {
    TestDocument.deserializationResult = .otherError

    let entity = NSEntityDescription.insertNewObject(forEntityName: TestDocument.documentDescriptor.name, into: context)
    entity.setValue(Data(), forKey: DocumentDataAttributeName)
    entity.setValue(false, forKey: TestDocument.isTest.storageInformation.propertyName.keyPath)

    do {
      _ = try transaction.fetch(matching: Query<TestDocument>())
      XCTFail("Expected error")
    } catch let error as TransactionError {
      guard case let .serializationFailed(underlyingError) = error else {
        XCTFail("Unexpected error type")
        return
      }
      XCTAssertEqual(underlyingError as NSError, TestDocument.error)
    } catch {
      XCTFail("Unexpected error type")
    }
  }

  func testFetchUndeserializableDocumentWithAbortResolution() {
    TestDocument.deserializationResult = .errorWithResolution(.abortOperation)

    let entity = NSEntityDescription.insertNewObject(forEntityName: TestDocument.documentDescriptor.name, into: context)
    entity.setValue(Data(), forKey: DocumentDataAttributeName)
    entity.setValue(false, forKey: TestDocument.isTest.storageInformation.propertyName.keyPath)

    do {
      _ = try transaction.fetch(matching: Query<TestDocument>())
      XCTFail("Expected error")
    } catch let error as TransactionError {
      guard case let .serializationFailed(underlyingError) = error else {
        XCTFail("Unexpected error type")
        return
      }
      XCTAssertEqual(underlyingError as NSError, TestDocument.error)
    } catch {
      XCTFail("Unexpected error type")
    }
  }

  func testFetchUndeserializableDocumentWithDeleteResolution() {
    TestDocument.deserializationResult = .errorWithResolution(.deleteDocument)

    let entity = NSEntityDescription.insertNewObject(forEntityName: TestDocument.documentDescriptor.name, into: context)
    entity.setValue(Data(), forKey: DocumentDataAttributeName)
    entity.setValue(false, forKey: TestDocument.isTest.storageInformation.propertyName.keyPath)

    do {
      let items = try transaction.fetch(matching: Query<TestDocument>())
      XCTAssertEqual(items.count, 0)
      XCTAssertEqual(context.deletedObjects.count, 1)
    } catch {
      XCTFail("Unexpected error type")
    }
  }

  func testFetchUndeserializableDocumentWithSkipResolution() {
    TestDocument.deserializationResult = .errorWithResolution(.skipDocument)

    let entity = NSEntityDescription.insertNewObject(forEntityName: TestDocument.documentDescriptor.name, into: context)
    entity.setValue(Data(), forKey: DocumentDataAttributeName)
    entity.setValue(false, forKey: TestDocument.isTest.storageInformation.propertyName.keyPath)

    do {
      let items = try transaction.fetch(matching: Query<TestDocument>())
      XCTAssertEqual(items.count, 0)
      XCTAssertEqual(context.deletedObjects.count, 0)
    } catch {
      XCTFail("Unexpected error type")
    }
  }

  func testFetchCorruptDocument() {
    let entity = NSEntityDescription.insertNewObject(forEntityName: TestDocument.documentDescriptor.name, into: context)
    entity.setValue(nil, forKey: DocumentDataAttributeName)
    entity.setValue(false, forKey: TestDocument.isTest.storageInformation.propertyName.keyPath)

    do {
      let items = try transaction.fetch(matching: Query<TestDocument>())
      XCTAssertEqual(items.count, 0)
      XCTAssertEqual(context.deletedObjects.count, 0)
      XCTAssertEqual(logger.loggedMessages.count, 2)
      XCTAssertEqual(logger.loggedMessages.first?.level, .error)
      XCTAssertEqual(logger.loggedMessages.first?.message, "Encountered corrupt \'\(DocumentDataAttributeName)\' attribute. (DocumentStoreError #5: Failed to retrieve \'\(DocumentDataAttributeName)\' attribute contents and cast it to `Data` for a \'TestDocument\' document. This is an error in the DocumentStore library, please report this issue.)")
      XCTAssertEqual(logger.loggedMessages.last?.level, .warn)
      XCTAssertEqual(logger.loggedMessages.last?.message, "Deserializing \'TestDocument\' document failed, recovering with \'skipDocument\' resolution. (DocumentStoreError #5: Failed to retrieve \'\(DocumentDataAttributeName)\' attribute contents and cast it to `Data` for a \'TestDocument\' document. This is an error in the DocumentStore library, please report this issue.)")
    } catch {
      XCTFail("Unexpected error type")
    }
  }

  // TODO: Create save test
//  func testAddThrowsOnSerializationError() {
//    var document = TestDocument()
//    document.serializationSucceeds = false
//
//    do {
//      try transaction.add(document: document)
//      XCTFail("Expected error")
//    } catch let error as TransactionError {
//      guard case let .serializationFailed(error) = error else {
//        XCTFail("Unexpecter error type")
//        return
//      }
//
//      XCTAssertEqual(error as NSError, TestDocument.error)
//    } catch {
//      XCTFail("Unexpected error type")
//    }
//  }

  // MARK: Exception scenarios

  func testCountContextFailure() {
    var query = Query<TestDocument>()
    let left = Expression<TestDocument, Bool>(forIndex: TestDocument.errorIndex)
    let right = Expression<TestDocument, Bool>(forConstantValue: false)
    query.predicate = Predicate(left: left, right: right, comparisonOperator: .equalTo)

    do {
      _ = try transaction.count(matching: query)
      XCTFail("Expected error")
    } catch let error as TransactionError {
      guard case let .documentStoreError(documentStoreError) = error else {
        XCTFail("Unexpected error type")
        return
      }

      XCTAssertEqual(documentStoreError.kind, .operationFailed)

      guard let exceptionError = documentStoreError.underlyingError as? ExceptionError else {
        XCTFail("Unexpected error type")
        return
      }
      XCTAssertEqual(exceptionError.exception.name.rawValue, "NSInvalidArgumentException")
    } catch {
      XCTFail("Unexpected error type")
    }
  }

  func testFetchContextFailure() {
    var query = Query<TestDocument>()
    let left = Expression<TestDocument, Bool>(forIndex: TestDocument.errorIndex)
    let right = Expression<TestDocument, Bool>(forConstantValue: false)
    query.predicate = Predicate(left: left, right: right, comparisonOperator: .equalTo)

    do {
      _ = try transaction.fetch(matching: query)
      XCTFail("Expected error")
    } catch let error as TransactionError {
      guard case let .documentStoreError(documentStoreError) = error else {
        XCTFail("Unexpected error type")
        return
      }

      XCTAssertEqual(documentStoreError.kind, .operationFailed)

      guard let exceptionError = documentStoreError.underlyingError as? ExceptionError else {
        XCTFail("Unexpected error type")
        return
      }
      XCTAssertEqual(exceptionError.exception.name.rawValue, "NSInvalidArgumentException")
    } catch {
      XCTFail("Unexpected error type")
    }
  }

  func testDeleteContextFailure() {
    var query = Query<TestDocument>()
    let left = Expression<TestDocument, Bool>(forIndex: TestDocument.errorIndex)
    let right = Expression<TestDocument, Bool>(forConstantValue: false)
    query.predicate = Predicate(left: left, right: right, comparisonOperator: .equalTo)

    do {
      _ = try transaction.delete(matching: query)
      XCTFail("Expected error")
    } catch let error as TransactionError {
      guard case let .documentStoreError(documentStoreError) = error else {
        XCTFail("Unexpected error type")
        return
      }

      XCTAssertEqual(documentStoreError.kind, .operationFailed)

      guard let exceptionError = documentStoreError.underlyingError as? ExceptionError else {
        XCTFail("Unexpected error type")
        return
      }
      XCTAssertEqual(exceptionError.exception.name.rawValue, "NSInvalidArgumentException")
    } catch {
      XCTFail("Unexpected error type")
    }
  }
}

private struct TestDocument: Document {
  enum DeserializationResult {
    case succeeds
    case errorWithResolution(DocumentDeserializationError.Resolution)
    case otherError
  }

  static let errorIndex = Index<TestDocument, Bool>(name: "errorIndex") { _ in false }
  static let isTest = Index<TestDocument, Bool>(name: "isTest") { _ in true }
  static let documentDescriptor = DocumentDescriptor<TestDocument>(name: "TestDocument", identifier: Identifier { _ in return UUID().uuidString }, indices: [TestDocument.isTest])

  static let data = Data([42])
  static let error = NSError(domain: "TestDomain", code: 42, userInfo: nil)

  static var deserializationResult = DeserializationResult.succeeds
  var serializationSucceeds = true

  static func encode(_ document: TestDocument) throws -> Data {
    if document.serializationSucceeds {
      return TestDocument.data
    } else {
      throw TestDocument.error
    }
  }

  static func decode(from data: Data) throws -> TestDocument {
    switch deserializationResult {
    case .succeeds:
      return TestDocument()
    case let .errorWithResolution(resolution):
      throw DocumentDeserializationError(resolution: resolution, underlyingError: TestDocument.error)
    case .otherError:
      throw TestDocument.error
    }
  }
}
