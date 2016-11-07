//
//  Sequence+DuplicatesTests.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 07-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import XCTest
@testable import DocumentStore

class SequenceDuplicatesTests: XCTestCase {

  func testEmptyInput() {
    let empty: [Int] = []
    XCTAssertEqual(empty.duplicates(), [])
  }

  func testOnlyOneUnique() {
    XCTAssertEqual([1].duplicates(), [])
  }

  func testOnlyOneDuplicate() {
    XCTAssertEqual([2, 2].duplicates(), [2])
  }

  func testTriplet() {
    XCTAssertEqual([3, 3, 3].duplicates(), [3])
  }

  func testMixedList() {
    XCTAssertEqual([3, 3, 3, 2, 2, 1].duplicates(), [2, 3])
  }
}
