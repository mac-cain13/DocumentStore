//
//  ReadTransactionTests.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 14-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import XCTest
@testable import DocumentStore

class ReadTransactionTests: XCTestCase {

  private var testTransaction = TestTransaction()
  private var transaction = ReadTransaction(transaction: TestTransaction())

  override func setUp() {
    super.setUp()
    testTransaction = TestTransaction()
    transaction = ReadTransaction(transaction: testTransaction)
  }

  func testCount() {
    do {
      let count = try transaction.count(TestDocument.all())
      XCTAssertEqual(count, 42)
      XCTAssertEqual(testTransaction.countCalls, 1)
      XCTAssertEqual(testTransaction.fetchCalls, 0)
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

private class TestTransaction: ReadableTransaction {
  var countCalls = 0
  var fetchCalls = 0

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
}
