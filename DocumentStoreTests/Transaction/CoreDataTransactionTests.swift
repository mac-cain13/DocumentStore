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
    indexProperty.name = TestDocument.isTest.identifier
    indexProperty.attributeType = .booleanAttributeType

    let entity = NSEntityDescription()
    entity.name = TestDocument.documentDescriptor.identifier
    entity.properties = [property, indexProperty]
    model.entities = [entity]

    container = NSPersistentContainer(name: UUID().uuidString, managedObjectModel: model)
    container.loadPersistentStores { (_, _) in }
    context = container.newBackgroundContext()
    logger = MockLogger()

    transaction = CoreDataTransaction(context: context, documentDescriptors: ValidatedDocumentDescriptors(documentDescriptors: [TestDocument.documentDescriptor.eraseType()]), logTo: logger)
  }

  // MARK: Unregistered document type

  func testCountWithUnregisteredDocumentType() {
    let transaction = CoreDataTransaction(context: context, documentDescriptors: ValidatedDocumentDescriptors(documentDescriptors: []), logTo: logger)

    let collection = MockCollection<TestDocument>()
    do {
      _ = try transaction.count(collection)
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

    let collection = MockCollection<TestDocument>()
    do {
      _ = try transaction.fetch(collection)
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

    let collection = MockCollection<TestDocument>()
    do {
      _ = try transaction.delete(collection)
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

  func testAddWithUnregisteredDocumentType() {
    let transaction = CoreDataTransaction(context: context, documentDescriptors: ValidatedDocumentDescriptors(documentDescriptors: []), logTo: logger)

    let document = TestDocument()
    do {
      _ = try transaction.add(document: document)
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

  // MARK: Happy flow tests

  func testCount() {
    let entity = NSEntityDescription.insertNewObject(forEntityName: TestDocument.documentDescriptor.identifier, into: context)
    entity.setValue(Data(), forKey: DocumentDataAttributeName)
    entity.setValue(false, forKey: TestDocument.isTest.identifier)

    do {
      let count = try transaction.count(TestDocument.all())
      XCTAssertEqual(count, 1)
    } catch {
      XCTFail("Unexpected error")
    }
  }

  func testFetch() {
    let entity = NSEntityDescription.insertNewObject(forEntityName: TestDocument.documentDescriptor.identifier, into: context)
    entity.setValue(Data(), forKey: DocumentDataAttributeName)
    entity.setValue(false, forKey: TestDocument.isTest.identifier)

    do {
      let items = try transaction.fetch(TestDocument.all())
      XCTAssertEqual(items.count, 1)
    } catch {
      XCTFail("Unexpected error")
    }
  }

  func testDelete() {
    NSEntityDescription.insertNewObject(forEntityName: TestDocument.documentDescriptor.identifier, into: context)

    do {
      let deletions = try transaction.delete(TestDocument.all())
      XCTAssertEqual(deletions, 1)
      XCTAssertEqual(context.deletedObjects.count, 1)
    } catch {
      XCTFail("Unexpected error")
    }
  }

  func testAdd() {
    let document = TestDocument()
    XCTAssertFalse(context.hasChanges)

    do {
      try transaction.add(document: document)
      XCTAssertTrue(context.hasChanges)
      XCTAssertEqual(context.insertedObjects.count, 1)

      guard let data = context.insertedObjects.first?.value(forKey: DocumentDataAttributeName) as? Data else {
        XCTFail("No data for inserted object")
        return
      }
      XCTAssertEqual(data, TestDocument.data)

      guard let bool = context.insertedObjects.first?.value(forKey: TestDocument.isTest.identifier) as? Bool else {
        XCTFail("No index for inserted object")
        return
      }
      XCTAssertEqual(bool, TestDocument.isTest.resolver(document))
    } catch {
      XCTFail("Unexpected error")
    }
  }

  func testSaveChanges() {
    let transaction = CoreDataTransaction(context: context, documentDescriptors: ValidatedDocumentDescriptors(documentDescriptors: []), logTo: logger)

    NSEntityDescription.insertNewObject(forEntityName: TestDocument.documentDescriptor.identifier, into: context)
    XCTAssertTrue(context.hasChanges)
    do {
      try transaction.saveChanges()
      XCTAssertFalse(context.hasChanges)
    } catch {
      XCTFail("Unexpected error")
    }
  }

  // MARK: Unhappy flow tests

  func testFetchUndeserializableDocumentWithOtherError() {
    TestDocument.deserializationResult = .otherError

    let entity = NSEntityDescription.insertNewObject(forEntityName: TestDocument.documentDescriptor.identifier, into: context)
    entity.setValue(Data(), forKey: DocumentDataAttributeName)
    entity.setValue(false, forKey: TestDocument.isTest.identifier)

    do {
      let _ = try transaction.fetch(TestDocument.all())
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

    let entity = NSEntityDescription.insertNewObject(forEntityName: TestDocument.documentDescriptor.identifier, into: context)
    entity.setValue(Data(), forKey: DocumentDataAttributeName)
    entity.setValue(false, forKey: TestDocument.isTest.identifier)

    do {
      let _ = try transaction.fetch(TestDocument.all())
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

    let entity = NSEntityDescription.insertNewObject(forEntityName: TestDocument.documentDescriptor.identifier, into: context)
    entity.setValue(Data(), forKey: DocumentDataAttributeName)
    entity.setValue(false, forKey: TestDocument.isTest.identifier)

    do {
      let items = try transaction.fetch(TestDocument.all())
      XCTAssertEqual(items.count, 0)
      XCTAssertEqual(context.deletedObjects.count, 1)
    } catch {
      XCTFail("Unexpected error type")
    }
  }

  func testFetchUndeserializableDocumentWithSkipResolution() {
    TestDocument.deserializationResult = .errorWithResolution(.skipDocument)

    let entity = NSEntityDescription.insertNewObject(forEntityName: TestDocument.documentDescriptor.identifier, into: context)
    entity.setValue(Data(), forKey: DocumentDataAttributeName)
    entity.setValue(false, forKey: TestDocument.isTest.identifier)

    do {
      let items = try transaction.fetch(TestDocument.all())
      XCTAssertEqual(items.count, 0)
      XCTAssertEqual(context.deletedObjects.count, 0)
    } catch {
      XCTFail("Unexpected error type")
    }
  }

  func testFetchCorruptDocument() {
    let entity = NSEntityDescription.insertNewObject(forEntityName: TestDocument.documentDescriptor.identifier, into: context)
    entity.setValue(nil, forKey: DocumentDataAttributeName)
    entity.setValue(false, forKey: TestDocument.isTest.identifier)

    do {
      let items = try transaction.fetch(TestDocument.all())
      XCTAssertEqual(items.count, 0)
      XCTAssertEqual(context.deletedObjects.count, 0)
      XCTAssertEqual(logger.loggedMessages.count, 2)
      XCTAssertEqual(logger.loggedMessages.first?.level, .error)
      XCTAssertEqual(logger.loggedMessages.first?.message, "Encountered corrupt \'_DocumentData\' attribute. (DocumentStoreError #5: Failed to retrieve \'_DocumentData\' attribute contents and cast it to `Data` for a \'TestDocument\' document. This is an error in the DocumentStore library, please report this issue.)")
      XCTAssertEqual(logger.loggedMessages.last?.level, .warn)
      XCTAssertEqual(logger.loggedMessages.last?.message, "Deserializing \'TestDocument\' document failed, recovering with \'skipDocument\' resolution. (DocumentStoreError #5: Failed to retrieve \'_DocumentData\' attribute contents and cast it to `Data` for a \'TestDocument\' document. This is an error in the DocumentStore library, please report this issue.)")
    } catch {
      XCTFail("Unexpected error type")
    }
  }

  func testAddThrowsOnSerializationError() {
    var document = TestDocument()
    document.serializationSucceeds = false

    do {
      try transaction.add(document: document)
      XCTFail("Expected error")
    } catch let error as TransactionError {
      guard case let .serializationFailed(error) = error else {
        XCTFail("Unexpecter error type")
        return
      }

      XCTAssertEqual(error as NSError, TestDocument.error)
    } catch {
      XCTFail("Unexpected error type")
    }
  }

  // MARK: Exception scenarios

  func testCountContextFailure() {
    var collection = MockCollection<TestDocument>()
    collection.predicate = Predicate(predicate: NSPredicate(format: "error = %d", 3))

    do {
      _ = try transaction.count(collection)
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
    var collection = MockCollection<TestDocument>()
    collection.predicate = Predicate(predicate: NSPredicate(format: "error = %d", 3))

    do {
      _ = try transaction.fetch(collection)
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
    var collection = MockCollection<TestDocument>()
    collection.predicate = Predicate(predicate: NSPredicate(format: "error = %d", 3))

    do {
      _ = try transaction.delete(collection)
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

private struct MockCollection<Type: Document>: DocumentStoreCollection {
  public typealias DocumentType = Type

  var predicate: Predicate<DocumentType>?
  var skip: UInt
  var limit: UInt?

  init() {
    self.predicate = nil
    self.skip = 0
    self.limit = nil
  }
}

private struct TestDocument: Document {
  enum DeserializationResult {
    case succeeds
    case errorWithResolution(DocumentDeserializationError.Resolution)
    case otherError
  }

  static let isTest = Index<TestDocument, Bool>(identifier: "isTest") { _ in true }
  static let documentDescriptor = DocumentDescriptor<TestDocument>(identifier: "TestDocument", indices: [TestDocument.isTest.eraseType()])

  static let data = Data(bytes: [42])
  static let error = NSError(domain: "TestDomain", code: 42, userInfo: nil)

  static var deserializationResult = DeserializationResult.succeeds
  var serializationSucceeds = true

  func serializeDocument() throws -> Data {
    if serializationSucceeds {
      return TestDocument.data
    } else {
      throw TestDocument.error
    }
  }

  static func deserializeDocument(from data: Data) throws -> TestDocument {
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
