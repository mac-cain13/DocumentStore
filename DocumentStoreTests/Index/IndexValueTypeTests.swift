//
//  IndexValueTypeTests.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 07-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import XCTest
@testable import DocumentStore

class IndexValueTypeTests: XCTestCase {

  func testBool() {
    XCTAssertEqual(Bool.indexStorageType, IndexStorageType.bool)
  }

  func testDate() {
    XCTAssertEqual(Date.indexStorageType, IndexStorageType.date)
  }

  func testDouble() {
    XCTAssertEqual(Double.indexStorageType, IndexStorageType.double)
  }

  func testInt() {
    XCTAssertEqual(Int.indexStorageType, IndexStorageType.int)
  }

  func testString() {
    XCTAssertEqual(String.indexStorageType, IndexStorageType.string)
  }

}
