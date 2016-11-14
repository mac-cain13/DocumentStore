//
//  ReadWriteTransactionTests.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 14-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import XCTest
@testable import DocumentStore

class ReadWriteTransactionTests: XCTestCase {

  private var testTransaction = TestTransaction()
  private var transaction = ReadWriteTransaction(transaction: TestTransaction())

  override func setUp() {
    super.setUp()
    testTransaction = TestTransaction()
    transaction = ReadWriteTransaction(transaction: testTransaction)
  }

  func testCount() {
    do {
      let count = try transaction.count(TestDocument.all())
      XCTAssertEqual(count, 42)
      XCTAssertEqual(testTransaction.countCalls, 1)
      XCTAssertEqual(testTransaction.fetchCalls, 0)
      XCTAssertEqual(testTransaction.deleteCalls, 0)
      XCTAssertEqual(testTransaction.addCalls, 0)
      XCTAssertEqual(testTransaction.saveCalls, 0)
    } catch {
      XCTFail("Unexpected error: \(error)")
    }
  }

  func testFetch() {
    do {
      let result = try transaction.fetch(TestDocument.all())
      XCTAssertEqual(result.count, 2)
      XCTAssertEqual(testTransaction.countCalls, 0)
      XCTAssertEqual(testTransaction.fetchCalls, 1)
      XCTAssertEqual(testTransaction.deleteCalls, 0)
      XCTAssertEqual(testTransaction.addCalls, 0)
      XCTAssertEqual(testTransaction.saveCalls, 0)
    } catch {
      XCTFail("Unexpected error: \(error)")
    }
  }

  func testDelete() {
    do {
      let count = try transaction.delete(TestDocument.all())
      XCTAssertEqual(count, 1)
      XCTAssertEqual(testTransaction.countCalls, 0)
      XCTAssertEqual(testTransaction.fetchCalls, 0)
      XCTAssertEqual(testTransaction.deleteCalls, 1)
      XCTAssertEqual(testTransaction.addCalls, 0)
      XCTAssertEqual(testTransaction.saveCalls, 0)
    } catch {
      XCTFail("Unexpected error: \(error)")
    }
  }

  func testAdd() {
    do {
      let document = TestDocument()
      try transaction.add(document: document)
      XCTAssertEqual(testTransaction.countCalls, 0)
      XCTAssertEqual(testTransaction.fetchCalls, 0)
      XCTAssertEqual(testTransaction.deleteCalls, 0)
      XCTAssertEqual(testTransaction.addCalls, 1)
      XCTAssertEqual(testTransaction.saveCalls, 0)
    } catch {
      XCTFail("Unexpected error: \(error)")
    }
  }

  func testSave() {
    do {
      try transaction.saveChanges()
      XCTAssertEqual(testTransaction.countCalls, 0)
      XCTAssertEqual(testTransaction.fetchCalls, 0)
      XCTAssertEqual(testTransaction.deleteCalls, 0)
      XCTAssertEqual(testTransaction.addCalls, 0)
      XCTAssertEqual(testTransaction.saveCalls, 1)
    } catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
}

private struct TestDocument: Document {
  static let documentDescriptor = DocumentDescriptor<TestDocument>(identifier: "", indices: [])

  func serializeDocument() throws -> Data {
    return Data()
  }

  static func deserializeDocument(from data: Data) throws -> TestDocument {
    return TestDocument()
  }
}

private class TestTransaction: ReadWritableTransaction {
  var countCalls = 0
  var fetchCalls = 0
  var deleteCalls = 0
  var addCalls = 0
  var saveCalls = 0

  func count<CollectionType: DocumentStoreCollection>(_ collection: CollectionType) throws -> Int {
    countCalls += 1
    return 42
  }

  func fetch<CollectionType: DocumentStoreCollection>(_ collection: CollectionType) throws -> [CollectionType.DocumentType] {
    fetchCalls += 1

    return [
      try? CollectionType.DocumentType.deserializeDocument(from: Data()),
      try? CollectionType.DocumentType.deserializeDocument(from: Data())
      ].flatMap { $0 }
  }

  @discardableResult
  func delete<CollectionType: DocumentStoreCollection>(_ collection: CollectionType) throws -> Int {
    deleteCalls += 1
    return 1
  }

  func add<DocumentType: Document>(document: DocumentType) throws {
    addCalls += 1
  }

  func saveChanges() throws {
    saveCalls += 1
  }
}
