//
//  DocumentStoreTests.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 13-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import XCTest
@testable import DocumentStore
import CoreData

class DocumentStoreTests: XCTestCase {

  private var mockManagedObjectModelService = MockManagedObjectModelService()
  private var mockTransactionFactory = MockTransactionFactory()

  override func setUp() {
    super.setUp()
    mockManagedObjectModelService = MockManagedObjectModelService()
    dependencyContainer.managedObjectModelService = mockManagedObjectModelService

    mockTransactionFactory = MockTransactionFactory()
    dependencyContainer.transactionFactory = mockTransactionFactory
  }

  override func tearDown() {
    dependencyContainer.restoreDefaults()
    super.tearDown()
  }

  private func createDocumentStore() -> DocumentStore {
    do {
      return try DocumentStore(identifier: "TestDocument", documentDescriptors: [])
    } catch {
      fatalError("Unexpected error")
    }
  }

  // MARK: Initializing

  func testEmptyIdentifier() {
    do {
      let _ = try DocumentStore(identifier: "", documentDescriptors: [])
      XCTFail("Expected error")
    } catch let error as DocumentStoreError {
      XCTAssertEqual(error.kind, .storeIdentifierInvalid)
      XCTAssertEqual(error.message, "The DocumentStore identifier may not be empty.")
      XCTAssertNil(error.underlyingError)
    } catch {
      XCTFail("Unexpected error type")
    }
  }

  func testUnderscoreIdentifier() {
    for identifier in ["_", "_Something"] {
      do {
        let _ = try DocumentStore(identifier: identifier, documentDescriptors: [])
        XCTFail("Expected error")
      } catch let error as DocumentStoreError {
        XCTAssertEqual(error.kind, .storeIdentifierInvalid)
        XCTAssertEqual(error.message, "`\(identifier)` is an invalid DocumentStore identifier, identifiers may not start with an `_`.")
        XCTAssertNil(error.underlyingError)
      } catch {
        XCTFail("Unexpected error type")
      }
    }
  }

  func testInitializerRethrowsValidationErrors() {
    mockManagedObjectModelService.validateSucceeds = false

    do {
      let _ = try DocumentStore(identifier: "TestStore", documentDescriptors: [])
      XCTFail("Error was expected")
    } catch let error as DocumentStoreError {
      XCTAssertEqual(mockManagedObjectModelService.validateCalls, 1)
      XCTAssertEqual(mockManagedObjectModelService.generateModelCalls, 0)
      XCTAssertEqual(error.kind, .documentDescriptionInvalid)
    } catch {
      XCTFail("Error of unexpected type")
    }
  }

  func testInitializerGeneratesModelIfValidationSucceeds() {
    mockManagedObjectModelService.validateSucceeds = true

    do {
      let _ = try DocumentStore(identifier: "TestStore", documentDescriptors: [])
      XCTAssertEqual(mockManagedObjectModelService.validateCalls, 1)
      XCTAssertEqual(mockManagedObjectModelService.generateModelCalls, 1)
    } catch {
      XCTFail("Unexpected error")
    }
  }

  func testInitializerLogs() {
    do {
      let logger = MockLogger()
      let _ = try DocumentStore(identifier: "TestDocument", documentDescriptors: [], logTo: logger)

      XCTAssertEqual(logger.loggedMessages.count, 3)
      XCTAssertEqual(logger.loggedMessages[0].level, .debug)
      XCTAssertEqual(logger.loggedMessages[0].message, "Validating document descriptors...")
      XCTAssertEqual(logger.loggedMessages[1].level, .debug)
      XCTAssertEqual(logger.loggedMessages[1].message, "Generating data model...")
      XCTAssertEqual(logger.loggedMessages[2].level, .debug)
      XCTAssertEqual(logger.loggedMessages[2].message, "Setting up persistent store...")
    } catch {
      XCTFail("Unexpected error")
    }
  }

  // MARK: Transactions

  func testReadWriteTransactionConfiguresContext() {
    let actionExpectation = expectation(description: "Action callback")

    let documentStore = createDocumentStore()
    let handler: (TransactionResult<Bool>) -> Void = { _ in }
    documentStore.readWrite(handler: handler) { _ in
      XCTAssertEqual(self.mockTransactionFactory.transactions.count, 1)
      guard let mockTransaction = self.mockTransactionFactory.transactions.last else {
        actionExpectation.fulfill()
        return (.discardChanges, false)
      }

      guard let mergePolicy = mockTransaction.context.mergePolicy as? NSMergePolicy else {
        XCTFail("No merge policy set")
        actionExpectation.fulfill()
        return (.discardChanges, false)
      }

      XCTAssertTrue(mergePolicy === NSMergePolicy.overwrite, "Wrong merge policy in use, changing policy may break existing code!")
      XCTAssertEqual(mockTransaction.context.queryGenerationToken, NSQueryGenerationToken.current)

      actionExpectation.fulfill()
      return (.discardChanges, true)
    }

    waitForExpectations(timeout: 2, handler: nil)
  }

  func testReadWriteTransactionLogsQueryGenerationError() {
    XCTFail("Check for log when setQueryGenerationFrom call fails")
  }

  func testReadWriteTransactionPassesResultToHandler() {
    XCTFail("Check if handler gets success result")
  }

  func testReadWriteTransactionPassesFailureToHandler() {
    XCTFail("Check if handler gets failure error")
  }

  func testReadWriteTransactionHandlesSaveChangesCommitAction() {
    XCTFail("Check if save changes is called")
  }

  func testReadWriteTransactionPassesSaveChangesFailureToHandler() {
    XCTFail("Check if save changes failure is logged")
  }

  func testReadWriteTransactionLogsSaveChangesFailure() {
    XCTFail("Check if save changes failure is logged")
  }

  func testHandlerCalledOnRequestedQueue() {
    XCTFail("Check if handler called on correct thread")
  }
}

private class MockManagedObjectModelService: ManagedObjectModelService {
  var validateSucceeds = true

  private(set) var validateCalls = 0
  private(set) var generateModelCalls = 0

  func validate(_ documentDescriptors: [AnyDocumentDescriptor], logTo logger: Logger) throws -> ValidatedDocumentDescriptors {
    validateCalls += 1

    if validateSucceeds {
      return ValidatedDocumentDescriptors(documentDescriptors: documentDescriptors)
    } else {
      throw DocumentStoreError(kind: .documentDescriptionInvalid, message: "Test error", underlyingError: nil)
    }
  }

  func generateModel(from validatedDocumentDescriptors: ValidatedDocumentDescriptors, logTo logger: Logger) -> NSManagedObjectModel {
    generateModelCalls += 1
    return NSManagedObjectModel()
  }
}

private class MockTransactionFactory: TransactionFactory {
  var transactions: [MockTransaction] = []

  func createTransaction(context: NSManagedObjectContext, documentDescriptors: ValidatedDocumentDescriptors, logTo logger: Logger) -> ReadWritableTransaction {
    let transaction = MockTransaction(context: context)
    transactions.append(transaction)
    return transaction
  }
}

private class MockTransaction: ReadWritableTransaction {
  let context: NSManagedObjectContext
  var saveChangesCount = 0

  init(context: NSManagedObjectContext) {
    self.context = context
  }

  func count<CollectionType: DocumentStoreCollection>(_ collection: CollectionType) throws -> Int {
    return 0
  }

  func fetch<CollectionType: DocumentStoreCollection>(_ collection: CollectionType) throws -> [CollectionType.DocumentType] {
    return []
  }

  func add<DocumentType: Document>(document: DocumentType) throws {}

  @discardableResult
  func delete<CollectionType: DocumentStoreCollection>(_ collection: CollectionType) throws -> Int {
    return 0
  }

  func saveChanges() throws {
    saveChangesCount += 1
  }
}
