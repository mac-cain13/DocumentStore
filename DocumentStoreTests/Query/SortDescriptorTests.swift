//
//  SortDescriptorTests.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 13-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import XCTest
@testable import DocumentStore

class SortDescriptorTests: XCTestCase {

  func testInitializer() {
    let nsSortDescriptor = NSSortDescriptor(key: "", ascending: false)
    let sortDescriptor = SortDescriptor<MockDocument>(forIndex: MockDocument.isTest, order: Order.descending)
    XCTAssertEqual(sortDescriptor.foundationSortDescriptor, nsSortDescriptor)
  }

  // MARK: Index sortdescriptors

  func testAscending() {
    let nsSortDescriptor = NSSortDescriptor(key: MockDocument.isTest.storageInformation.propertyName.keyPath, ascending: true)
    XCTAssertEqual(MockDocument.isTest.ascending().foundationSortDescriptor, nsSortDescriptor)
  }

  func testDescending() {
    let nsSortDescriptor = NSSortDescriptor(key: MockDocument.isTest.storageInformation.propertyName.keyPath, ascending: false)
    XCTAssertEqual(MockDocument.isTest.descending().foundationSortDescriptor, nsSortDescriptor)
  }
}
