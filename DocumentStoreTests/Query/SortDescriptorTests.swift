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
  func testAscending() {
    let nsSortDescriptor = NSSortDescriptor(key: MockDocument.isTest.storageInformation.propertyName.keyPath, ascending: true)
    XCTAssertEqual(SortDescriptor(index: MockDocument.isTest, order: .ascending).foundationSortDescriptor, nsSortDescriptor)
  }

  func testDescending() {
    let nsSortDescriptor = NSSortDescriptor(key: MockDocument.isTest.storageInformation.propertyName.keyPath, ascending: false)
    XCTAssertEqual(SortDescriptor(index: MockDocument.isTest, order: .descending).foundationSortDescriptor, nsSortDescriptor)
  }
}
