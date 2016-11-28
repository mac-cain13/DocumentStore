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
    XCTAssertEqual(query.predicate?.foundationPredicate, predicate.foundationPredicate)

    query = query.filtered { _ in predicate }
    XCTAssertEqual(query.predicate?.foundationPredicate, (predicate && predicate).foundationPredicate)
  }

  // MARK: Sorting

  func testSorted() {

    let sortDescriptor = TestDocument.isTest.ascending()
    var orderedQuery = query.sorted { _ in sortDescriptor }
    XCTAssertEqual(orderedQuery.sortDescriptors.map { $0.foundationSortDescriptor }, [sortDescriptor.foundationSortDescriptor])

    let otherSortDescriptor = TestDocument.isTest.descending()
    orderedQuery = orderedQuery.sorted { _ in otherSortDescriptor }
    XCTAssertEqual(orderedQuery.sortDescriptors.map { $0.foundationSortDescriptor }, [otherSortDescriptor.foundationSortDescriptor])
  }

  func testThenSorted() {
    let appendedSortDescriptor = TestDocument.isTest.ascending()

    var query = self.query
    query.sortDescriptors = [TestDocument.isTest.descending()]

    let sortedQuery = query.thenSorted { _ in appendedSortDescriptor }
    let allSortDescriptors = query.sortDescriptors + [appendedSortDescriptor]
    XCTAssertEqual(sortedQuery.sortDescriptors.map { $0.foundationSortDescriptor }, allSortDescriptors.map { $0.foundationSortDescriptor })
  }
}

private struct TestDocument: Document {
  static let isTest = Index<TestDocument, Bool>(name: "") { _ in false }
  static let documentDescriptor = DocumentDescriptor<TestDocument>(name: "", indices: [])

  func serializeDocument() throws -> Data {
    return Data()
  }

  static func deserializeDocument(from data: Data) throws -> TestDocument {
    return TestDocument()
  }
}
