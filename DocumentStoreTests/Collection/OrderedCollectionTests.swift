//
//  OrderedCollectionTests.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 13-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import XCTest
@testable import DocumentStore

class OrderedCollectionTests: XCTestCase {

  private let predicate = Predicate<TestDocument>(predicate: NSPredicate(value: false))
  private let skip: UInt = 42
  private let limit: UInt = 1
  private let sortDescriptors = [SortDescriptor<TestDocument>(sortDescriptor: NSSortDescriptor(key: "TestKey", ascending: false))]

  private var collection: OrderedCollection<TestDocument>!

  override func setUp() {
    super.setUp()

    var origCollection = TestCollection()
    origCollection = TestCollection()
    origCollection.predicate = predicate
    origCollection.skip = skip
    origCollection.limit = limit

    collection = OrderedCollection(collection: origCollection, sortDescriptors: sortDescriptors)
  }

  func testInitialValues() {
    XCTAssertEqual(collection.predicate?.predicate, predicate.predicate)
    XCTAssertEqual(collection.skip, skip)
    XCTAssertEqual(collection.limit, limit)
    XCTAssertEqual(collection.sortDescriptors.map { $0.sortDescriptor }, sortDescriptors.map { $0.sortDescriptor })
  }

  func testThenBy() {
    let appendedSortDescriptor = TestDocument.isTest.ascending()
    let collection = self.collection.thenBy { _ in appendedSortDescriptor }

    let allSortDescriptors = sortDescriptors + [appendedSortDescriptor]
    XCTAssertEqual(collection.sortDescriptors.map { $0.sortDescriptor }, allSortDescriptors.map { $0.sortDescriptor })
  }
}

private struct TestDocument: Document {
  static let isTest = Index<TestDocument, Bool>(identifier: "") { _ in false }
  static let documentDescriptor = DocumentDescriptor<TestDocument>(identifier: "", indices: [])

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
