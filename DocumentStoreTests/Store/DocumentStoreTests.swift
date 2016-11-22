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
  private var mockPersistentContainerFactory = MockPersistentContainerFactory()
  private var mockTransactionFactory = MockTransactionFactory()

  override func setUp() {
    super.setUp()
    mockManagedObjectModelService = MockManagedObjectModelService()
    dependencyContainer.managedObjectModelService = mockManagedObjectModelService

    mockPersistentContainerFactory = MockPersistentContainerFactory()
    dependencyContainer.persistentContainerFactory = mockPersistentContainerFactory

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

  func testFailedPersistentStoreLoadingLogs() {
    do {
      let logger = MockLogger()
      mockPersistentContainerFactory.createdContainersLoadingShouldSucceed = false
      let _ = try DocumentStore(identifier: "TestDocument", documentDescriptors: [], logTo: logger)

      let errorLogExpectation = expectation(description: "Error log")
      logger.logCallback = { logMessage in
        XCTAssertEqual(logMessage.level, .error)
        XCTAssertEqual(logMessage.message, "Failed to load persistent store, this will result in an unusable DocumentStore. (\(MockPersistentContainer.loadError))")
        errorLogExpectation.fulfill()
      }
      waitForExpectations(timeout: 2)
    } catch {
      XCTFail("Unexpected error")
    }
  }

  // MARK: Transactions

  func testReadWriteTransactionConfiguresContext() {
    let documentStore = createDocumentStore()
    let actionExpectation = expectation(description: "Action callback")
    let handler: (TransactionResult<Bool>) -> Void = { _ in }

    documentStore.readWrite(handler: handler) { _ in
      XCTAssertEqual(self.mockTransactionFactory.transactions.count, 1)
      guard let mockTransaction = self.mockTransactionFactory.transactions.last else {
        XCTFail("No mock transaction")
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

    waitForExpectations(timeout: 2)
  }

  func testReadWriteTransactionPassesResultToHandler() {
    let handlerExpectation = expectation(description: "Handler callback")
    let handler: (TransactionResult<Bool>) -> Void = { result in
      guard case TransactionResult.success(true) = result else {
        XCTFail("Expected true result")
        handlerExpectation.fulfill()
        return
      }
      handlerExpectation.fulfill()
    }

    let documentStore = createDocumentStore()
    documentStore.readWrite(handler: handler) { _ in (.discardChanges, true) }

    waitForExpectations(timeout: 2)
  }

  func testReadWriteTransactionPassesFailureToHandler() {
    let error = NSError(domain: "TestDomain", code: 42, userInfo: nil)

    let handlerExpectation = expectation(description: "Handler callback")
    let handler: (TransactionResult<Bool>) -> Void = { result in
      guard case let TransactionResult.failure(.actionThrewError(receivedError)) = result else {
        XCTFail("Expected true result")
        handlerExpectation.fulfill()
        return
      }

      XCTAssertEqual(receivedError as NSError, error)
      handlerExpectation.fulfill()
    }

    let documentStore = createDocumentStore()
    documentStore.readWrite(handler: handler) { _ in throw error }

    waitForExpectations(timeout: 2)
  }

  func testReadWriteTransactionHandlesSaveChangesCommitAction() {
    let handlerExpectation = expectation(description: "Handler callback")
    let handler: (TransactionResult<Bool>) -> Void = { _ in
      XCTAssertEqual(self.mockTransactionFactory.transactions.count, 1)
      guard let mockTransaction = self.mockTransactionFactory.transactions.last else {
        XCTFail("No mock transaction")
        handlerExpectation.fulfill()
        return
      }

      XCTAssertEqual(mockTransaction.saveChangesCount, 1)
      handlerExpectation.fulfill()
    }

    let documentStore = createDocumentStore()
    documentStore.readWrite(handler: handler) { _ in (.saveChanges, false) }
    waitForExpectations(timeout: 2)
  }

  func testReadWriteTransactionPassesSaveChangesFailureToHandler() {
    let handlerExpectation = expectation(description: "Handler callback")
    let handler: (TransactionResult<Bool>) -> Void = { result in
      guard case let .failure(.documentStoreError(error)) = result else {
        XCTFail("Unexpected transaction result")
        handlerExpectation.fulfill()
        return
      }

      XCTAssertEqual(error.kind, .operationFailed)
      XCTAssertEqual(error.message, "Failed to save changes from a transaction to the store.")
      XCTAssertEqual(error.underlyingError as? NSError, MockSaveErrorTransaction.saveError)
      handlerExpectation.fulfill()
    }

    let documentStore = createDocumentStore()
    documentStore.readWrite(handler: handler) { _ in
      XCTAssertEqual(self.mockTransactionFactory.transactions.count, 1)
      guard let mockTransaction = self.mockTransactionFactory.transactions.last else {
        XCTFail("No mock transaction")
        handlerExpectation.fulfill()
        return (.discardChanges, false)
      }

      mockTransaction.savingShouldSucceed = false
      return (.saveChanges, false)
    }

    waitForExpectations(timeout: 2)
  }

  func testHandlerCalledOnRequestedQueue() {
    let queueKey = DispatchSpecificKey<Void>()
    let queue = DispatchQueue(label: "TestQueue")
    queue.setSpecific(key: queueKey, value: ())

    let handlerExpectation = expectation(description: "Action callback")
    let handler: (TransactionResult<Bool>) -> Void = { _ in
      XCTAssertNotNil(DispatchQueue.getSpecific(key: queueKey), "Handler not called on expected queue")
      handlerExpectation.fulfill()
    }

    let documentStore = createDocumentStore()
    documentStore.readWrite(queue: queue, handler: handler, actions: { _ in (.discardChanges, false) })

    waitForExpectations(timeout: 2)
  }

  func testReadCallsHandler() {
    let handlerExpectation = expectation(description: "Handler callback")
    let handler: (TransactionResult<Bool>) -> Void = { result in
      guard case TransactionResult.success(true) = result else {
        XCTFail("Expected true result")
        handlerExpectation.fulfill()
        return
      }
      handlerExpectation.fulfill()
    }

    let documentStore = createDocumentStore()
    documentStore.read(handler: handler) { _ in true }

    waitForExpectations(timeout: 2)
  }

  func testWriteCallsHandler() {
    let handlerExpectation = expectation(description: "Handler callback")
    let handler: (TransactionResult<Void>) -> Void = { result in
      guard case TransactionResult.success(()) = result else {
        XCTFail("Expected void result")
        handlerExpectation.fulfill()
        return
      }
      handlerExpectation.fulfill()
    }

    let documentStore = createDocumentStore()
    documentStore.write(handler: handler) { _ in .discardChanges }

    waitForExpectations(timeout: 2)
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
  private(set) var transactions: [MockSaveErrorTransaction] = []

  func createTransaction(context: NSManagedObjectContext, documentDescriptors: ValidatedDocumentDescriptors, logTo logger: Logger) -> ReadWritableTransaction {
    let transaction = MockSaveErrorTransaction(context: context)
    transactions.append(transaction)
    return transaction
  }
}

private class MockSaveErrorTransaction: ReadWritableTransaction {
  static let saveError = NSError(domain: "TestDomain", code: 42, userInfo: nil)

  let context: NSManagedObjectContext
  private(set) var saveChangesCount = 0

  var savingShouldSucceed = true

  init(context: NSManagedObjectContext) {
    self.context = context
  }

  func count<DocumentType>(matching query: Query<DocumentType>) throws -> Int {
    return 0
  }

  func fetch<DocumentType>(matching query: Query<DocumentType>) throws -> [DocumentType] {
    return []
  }

  func add<DocumentType: Document>(document: DocumentType) throws {}

  @discardableResult
  func delete<DocumentType>(matching query: Query<DocumentType>) throws -> Int {
    return 0
  }

  func saveChanges() throws {
    saveChangesCount += 1

    if !savingShouldSucceed {
      throw MockSaveErrorTransaction.saveError
    }
  }
}

private class MockPersistentContainerFactory: PersistentContainerFactory {
  var createdContainersLoadingShouldSucceed = true

  private(set) var containers: [MockPersistentContainer] = []

  func createPersistentContainer(name: String, managedObjectModel: NSManagedObjectModel) -> NSPersistentContainer {
    let container = MockPersistentContainer(name: name, managedObjectModel: managedObjectModel)
    container.loadingShouldSucceed = createdContainersLoadingShouldSucceed
    containers.append(container)
    return container
  }
}

private class MockPersistentContainer: NSPersistentContainer {
  static let loadError = NSError(domain: "TestDomain", code: 42, userInfo: nil)
  var loadingShouldSucceed = true

  override func loadPersistentStores(completionHandler block: @escaping (NSPersistentStoreDescription, Error?) -> Void) {
    if loadingShouldSucceed {
      super.loadPersistentStores(completionHandler: block)
    } else {
      guard let description = persistentStoreDescriptions.first else { fatalError("No description for mock persistent container.") }
      DispatchQueue.main.async { block(description, MockPersistentContainer.loadError) }
    }
  }
}
