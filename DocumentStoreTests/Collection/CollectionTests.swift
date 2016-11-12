//
//  CollectionTests.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 12-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import XCTest
@testable import DocumentStore
import CoreData

class CollectionTests: XCTestCase {

  private struct TestDocument: Document {
    static let isTest = Index<TestDocument, Bool>(identifier: "isTest") { _ in false }

    static let documentDescriptor = DocumentDescriptor<TestDocument>(identifier: "TestDocument", indices: [])

    func serializeDocument() throws -> Data {
      return Data()
    }

    static func deserializeDocument(from data: Data) throws -> TestDocument {
      return TestDocument()
    }
  }

  private struct TestCollection: DocumentStoreCollection {
    typealias DocumentType = TestDocument

    var predicate: Predicate<DocumentType>?
    var skip: UInt
    var limit: UInt?

    init() {
      self.predicate = nil
      self.skip = 0
      self.limit = nil
    }
  }

  private class TestTransaction: ReadWritableTransaction {
    var countCalls = 0
    var fetchCalls = 0
    var deleteCalls = 0
    var addCalls = 0
    var saveChangesCalls = 0

    var fetchLimitCallback: ((UInt?) -> Void)?

    func count<CollectionType: DocumentStoreCollection>(_ collection: CollectionType) throws -> Int {
      countCalls += 1
      return 2
    }

    func fetch<CollectionType: DocumentStoreCollection>(_ collection: CollectionType) throws -> [CollectionType.DocumentType] {
      fetchLimitCallback?(collection.limit)

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
      saveChangesCalls += 1
    }
  }

  private var collection = TestCollection()

  override func setUp() {
    super.setUp()
    collection = TestCollection()
  }

  // MARK: Limiting

  func testSkipping() {
    XCTAssertEqual(collection.skip, 0)

    collection = collection.skipping(upTo: 3)
    XCTAssertEqual(collection.skip, 3)

    collection = collection.skipping(upTo: 0)
    XCTAssertEqual(collection.skip, 3)

    collection = collection.skipping(upTo: 1)
    XCTAssertEqual(collection.skip, 4)
  }

  func testLimiting() {
    XCTAssertNil(collection.limit)

    collection = collection.limiting(upTo: 3)
    XCTAssertEqual(collection.limit, 3)

    collection = collection.limiting(upTo: 2)
    XCTAssertEqual(collection.limit, 2)

    collection = collection.limiting(upTo: 3)
    XCTAssertEqual(collection.limit, 2)
  }

  // MARK: Filtering

  func testFiltering() {
    XCTAssertNil(collection.predicate)

    let predicate: Predicate<TestDocument> = TestDocument.isTest == false
    collection = collection.filtering { _ in predicate }
    XCTAssertEqual(collection.predicate?.predicate, predicate.predicate)

    collection = collection.filtering { _ in predicate }
    XCTAssertEqual(collection.predicate?.predicate, (predicate && predicate).predicate)
  }

  func testExcluding() {
    XCTAssertNil(collection.predicate)

    let predicate: Predicate<TestDocument> = TestDocument.isTest == false
    collection = collection.excluding { _ in predicate }
    XCTAssertEqual(collection.predicate?.predicate, (!predicate).predicate)

    collection = collection.excluding { _ in predicate }
    XCTAssertEqual(collection.predicate?.predicate, (!predicate && !predicate).predicate)
  }

  // MARK: Ordering

  func testOrdered() {

    let sortDescriptor = TestDocument.isTest.ascending()
    var orderedCollection = collection.ordered { _ in sortDescriptor }
    XCTAssertEqual(orderedCollection.sortDescriptors.map { $0.sortDescriptor }, [sortDescriptor.sortDescriptor])

    let otherSortDescriptor = TestDocument.isTest.descending()
    orderedCollection = orderedCollection.ordered { _ in otherSortDescriptor }
    XCTAssertEqual(orderedCollection.sortDescriptors.map { $0.sortDescriptor }, [otherSortDescriptor.sortDescriptor])
  }

  // MARK: Fetching

  func testCount() {
    let testTransaction = TestTransaction()
    let transaction = ReadWriteTransaction(transaction: testTransaction)

    do {
      let result = try collection.count(in: transaction)
      XCTAssertEqual(result, 2)
      XCTAssertEqual(testTransaction.countCalls, 1)
    } catch {
      XCTFail("Unexpected error")
    }
  }

  func testArray() {
    let testTransaction = TestTransaction()
    testTransaction.fetchLimitCallback = { XCTAssertNil($0) }

    let transaction = ReadWriteTransaction(transaction: testTransaction)

    do {
      let result = try collection.array(in: transaction)
      XCTAssertEqual(result.count, 2)
      XCTAssertEqual(testTransaction.fetchCalls, 1)
    } catch {
      XCTFail("Unexpected error")
    }
  }

  func testFirst() {
    let testTransaction = TestTransaction()
    testTransaction.fetchLimitCallback = { XCTAssertEqual($0, 1) }

    let transaction = ReadWriteTransaction(transaction: testTransaction)

    do {
      let result = try collection.first(in: transaction)
      XCTAssertNotNil(result)
      XCTAssertEqual(testTransaction.fetchCalls, 1)
    } catch {
      XCTFail("Unexpected error")
    }
  }

  func testDelete() {
    let testTransaction = TestTransaction()
    let transactions = ReadWriteTransaction(transaction: testTransaction)

    do {
      let result = try collection.delete(in: transactions)
      XCTAssertEqual(result, 1)
      XCTAssertEqual(testTransaction.deleteCalls, 1)
    } catch {
      XCTFail("Unexpected error")
    }
  }
}
