//
//  ExpressionTests.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 13-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import XCTest
@testable import DocumentStore

class ExpressionTests: XCTestCase {

  func testInitializationWithConstant() {
    let expression = Expression<MockDocument, Bool>(forConstantValue: false)
    XCTAssertEqual(expression.foundationExpression, NSExpression(forConstantValue: false))
  }

  func testInitializationWithIndex() {
    let expression = Expression<MockDocument, Bool>(forIndex: MockDocument.isTest)
    XCTAssertEqual(expression.foundationExpression, NSExpression(forKeyPath: MockDocument.isTest.storageInformation.propertyName.keyPath))
  }
}
