//
//  IndexStorageTypeTests.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 07-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import XCTest
@testable import DocumentStore
import CoreData

class IndexStorageTypeTests: XCTestCase {

  func testBool() {
    XCTAssertEqual(IndexStorageType.bool.attributeType, NSAttributeType.booleanAttributeType)
  }

  func testDate() {
    XCTAssertEqual(IndexStorageType.date.attributeType, NSAttributeType.dateAttributeType)
  }

  func testDouble() {
    XCTAssertEqual(IndexStorageType.double.attributeType, NSAttributeType.doubleAttributeType)
  }

  func testInt() {
    XCTAssertEqual(IndexStorageType.int.attributeType, NSAttributeType.integer64AttributeType)
  }

  func testString() {
    XCTAssertEqual(IndexStorageType.string.attributeType, NSAttributeType.stringAttributeType)
  }

}
