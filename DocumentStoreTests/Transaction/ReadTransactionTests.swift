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

  private var testTransaction = MockTransaction()
  private var transaction = ReadTransaction(transaction: MockTransaction())

  override func setUp() {
    super.setUp()
    testTransaction = MockTransaction()
    transaction = ReadTransaction(transaction: testTransaction)
  }

  func testCount() {
    do {
      let count = try transaction.count(matching: Query<TestDocument>())
      XCTAssertEqual(count, 42)
      XCTAssertEqual(testTransaction.countCalls, 1)
      XCTAssertEqual(testTransaction.fetchCalls, 0)
    } catch {
      XCTFail("Unexpected error: \(error)")
    }
  }

  func testFetch() {
    do {
      let result = try transaction.fetch(matching: Query<TestDocument>())
      XCTAssertEqual(result.count, 2)
      XCTAssertEqual(testTransaction.countCalls, 0)
      XCTAssertEqual(testTransaction.fetchCalls, 1)
    } catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
}

private struct TestDocument: Codable, Document {
  static let documentDescriptor = DocumentDescriptor<TestDocument>(
    name: "",
    identifier: Identifier { _ in return UUID().uuidString },
    indices: []
  )
}
