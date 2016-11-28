//
//  StorageTypeTests.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 07-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import XCTest
@testable import DocumentStore
import CoreData

class StorageTypeTests: XCTestCase {

  func testBool() {
    XCTAssertEqual(StorageType.bool.attributeType, NSAttributeType.booleanAttributeType)
  }

  func testDate() {
    XCTAssertEqual(StorageType.date.attributeType, NSAttributeType.dateAttributeType)
  }

  func testDouble() {
    XCTAssertEqual(StorageType.double.attributeType, NSAttributeType.doubleAttributeType)
  }

  func testInt() {
    XCTAssertEqual(StorageType.int.attributeType, NSAttributeType.integer64AttributeType)
  }

  func testString() {
    XCTAssertEqual(StorageType.string.attributeType, NSAttributeType.stringAttributeType)
  }

}
