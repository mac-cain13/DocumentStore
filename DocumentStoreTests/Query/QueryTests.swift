//
//  QueryTests.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 12-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import XCTest
@testable import DocumentStore

class QueryTests: XCTestCase {

  private var query = Query<TestDocument>()

  override func setUp() {
    super.setUp()
    query = Query<TestDocument>()
  }

  func testNoRestrictionsByDefault() {
    XCTAssertNil(query.predicate)
    XCTAssertEqual(query.skip, 0)
    XCTAssertNil(query.limit)
  }

  // MARK: Limiting

  func testSkipping() {
    XCTAssertEqual(query.skip, 0)

    query = query.skipping(upTo: 3)
    XCTAssertEqual(query.skip, 3)

    query = query.skipping(upTo: 0)
    XCTAssertEqual(query.skip, 3)

    query = query.skipping(upTo: 1)
    XCTAssertEqual(query.skip, 4)
  }

  func testLimited() {
    XCTAssertNil(query.limit)

    query = query.limited(upTo: 3)
    XCTAssertEqual(query.limit, 3)

    query = query.limited(upTo: 2)
    XCTAssertEqual(query.limit, 2)

    query = query.limited(upTo: 3)
    XCTAssertEqual(query.limit, 2)
  }

  // MARK: Filtering

  func testFiltered() {
    XCTAssertNil(query.predicate)

    let predicate: Predicate<TestDocument> = TestDocument.isTest == false
    query = query.filtered { _ in predicate }
    XCTAssertEqual(query.predicate?.predicate, predicate.predicate)

    query = query.filtered { _ in predicate }
    XCTAssertEqual(query.predicate?.predicate, (predicate && predicate).predicate)
  }

  // MARK: Sorting

  func testSorted() {

    let sortDescriptor = TestDocument.isTest.ascending()
    var orderedQuery = query.sorted { _ in sortDescriptor }
    XCTAssertEqual(orderedQuery.sortDescriptors.map { $0.sortDescriptor }, [sortDescriptor.sortDescriptor])

    let otherSortDescriptor = TestDocument.isTest.descending()
    orderedQuery = orderedQuery.sorted { _ in otherSortDescriptor }
    XCTAssertEqual(orderedQuery.sortDescriptors.map { $0.sortDescriptor }, [otherSortDescriptor.sortDescriptor])
  }

  func testThenSorted() {
    let appendedSortDescriptor = TestDocument.isTest.ascending()

    var query = self.query
    query.sortDescriptors = [SortDescriptor<TestDocument>(sortDescriptor: NSSortDescriptor(key: "TestKey", ascending: false))]

    let sortedQuery = query.thenSorted { _ in appendedSortDescriptor }
    let allSortDescriptors = query.sortDescriptors + [appendedSortDescriptor]
    XCTAssertEqual(sortedQuery.sortDescriptors.map { $0.sortDescriptor }, allSortDescriptors.map { $0.sortDescriptor })
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
