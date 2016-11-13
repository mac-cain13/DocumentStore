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

  private let leftExpression = NSExpression(forKeyPath: "Left")
  private let rightExpression = NSExpression(forKeyPath: "Right")

  func testEqualTo() {
    let predicate = NSComparisonPredicate(
      leftExpression: leftExpression,
      rightExpression: rightExpression,
      modifier: .direct,
      type: .equalTo,
      options: .init(rawValue: 0)
    )
    XCTAssertEqual(leftExpression == rightExpression, predicate)
  }

  func testNotEqualTo() {
    let predicate = NSComparisonPredicate(
      leftExpression: leftExpression,
      rightExpression: rightExpression,
      modifier: .direct,
      type: .notEqualTo,
      options: .init(rawValue: 0)
    )
    XCTAssertEqual(leftExpression != rightExpression, predicate)
  }

  func testGreaterThan() {
    let predicate = NSComparisonPredicate(
      leftExpression: leftExpression,
      rightExpression: rightExpression,
      modifier: .direct,
      type: .greaterThan,
      options: .init(rawValue: 0)
    )
    XCTAssertEqual(leftExpression > rightExpression, predicate)
  }

  func testGreaterThanOrEqualTo() {
    let predicate = NSComparisonPredicate(
      leftExpression: leftExpression,
      rightExpression: rightExpression,
      modifier: .direct,
      type: .greaterThanOrEqualTo,
      options: .init(rawValue: 0)
    )
    XCTAssertEqual(leftExpression >= rightExpression, predicate)
  }

  func testLessThan() {
    let predicate = NSComparisonPredicate(
      leftExpression: leftExpression,
      rightExpression: rightExpression,
      modifier: .direct,
      type: .lessThan,
      options: .init(rawValue: 0)
    )
    XCTAssertEqual(leftExpression < rightExpression, predicate)
  }

  func testLessThanOrEqualTo() {
    let predicate = NSComparisonPredicate(
      leftExpression: leftExpression,
      rightExpression: rightExpression,
      modifier: .direct,
      type: .lessThanOrEqualTo,
      options: .init(rawValue: 0)
    )
    XCTAssertEqual(leftExpression <= rightExpression, predicate)
  }

  func testLike() {
    let predicate = NSComparisonPredicate(
      leftExpression: leftExpression,
      rightExpression: rightExpression,
      modifier: .direct,
      type: .like,
      options: .init(rawValue: 0)
    )
    XCTAssertEqual(leftExpression ~= rightExpression, predicate)
  }
}
