//
//  StorableValueTests.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 07-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import XCTest
@testable import DocumentStore

class StorableValueTests: XCTestCase {

  func testBool() {
    XCTAssertEqual(Bool.storageType, StorageType.bool)
  }

  func testDate() {
    XCTAssertEqual(Date.storageType, StorageType.date)
  }

  func testDouble() {
    XCTAssertEqual(Double.storageType, StorageType.double)
  }

  func testInt() {
    XCTAssertEqual(Int.storageType, StorageType.int)
  }

  func testString() {
    XCTAssertEqual(String.storageType, StorageType.string)
  }

}
