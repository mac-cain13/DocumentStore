//
//  PredicateTests.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 13-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import XCTest
@testable import DocumentStore

class PredicateTests: XCTestCase {

  private let left = NSExpression(forKeyPath: TestDocument.isTest.identifier)
  private let right = NSExpression(forConstantValue: false)

  func testInitializer() {
    let nsPredicate = NSPredicate(value: false)
    let predicate = Predicate<TestDocument>(predicate: nsPredicate)
    XCTAssertEqual(predicate.predicate, nsPredicate)
  }

  // MARK: Basic predicate operators

  func testEquals() {
    let predicate = (TestDocument.isTest == false).predicate
    XCTAssertEqual(predicate, left == right)
  }

  func testNotEqualTo() {
    let predicate = (TestDocument.isTest != false).predicate
    XCTAssertEqual(predicate, left != right)
  }

  func testGreaterThan() {
    let predicate = (TestDocument.isTest > false).predicate
    XCTAssertEqual(predicate, left > right)
  }

  func testGreaterThanOrEqualTo() {
    let predicate = (TestDocument.isTest >= false).predicate
    XCTAssertEqual(predicate, left >= right)
  }

  func testLessThan() {
    let predicate = (TestDocument.isTest < false).predicate
    XCTAssertEqual(predicate, left < right)
  }

  func testLessThanOrEqualTo() {
    let predicate = (TestDocument.isTest <= false).predicate
    XCTAssertEqual(predicate, left <= right)
  }

  func testLike() {
    let predicate = (TestDocument.isTestString ~= "").predicate
    XCTAssertEqual(predicate, left ~= right)
  }

  // MARK: Predicate modifiers

  func testNot() {
    let predicate = TestDocument.isTest == false
    let notPredicate = !predicate
    XCTAssertEqual(notPredicate.predicate, NSCompoundPredicate(type: .not, subpredicates: [predicate.predicate]))
  }

  // MARK: Predicate combinators

  func testAndWithNil() {
    let predicate = TestDocument.isTest == false
    let combinedPredicate = nil && predicate
    XCTAssertEqual(combinedPredicate.predicate, predicate.predicate)
  }

  func testAnd() {
    let predicate = TestDocument.isTest == false
    let combinedPredicate = predicate && predicate
    XCTAssertEqual(combinedPredicate.predicate, NSCompoundPredicate(type: .and, subpredicates: [predicate.predicate, predicate.predicate]))
  }

  func testOr() {
    let predicate = TestDocument.isTest == false
    let combinedPredicate = predicate || predicate
    XCTAssertEqual(combinedPredicate.predicate, NSCompoundPredicate(type: .or, subpredicates: [predicate.predicate, predicate.predicate]))
  }
}

private struct TestDocument: Document {
  static let isTest = Index<TestDocument, Bool>(identifier: "") { _ in false }
  static let isTestString = Index<TestDocument, String>(identifier: "") { _ in "" }
  static let documentDescriptor = DocumentDescriptor<TestDocument>(identifier: "", indices: [])

  func serializeDocument() throws -> Data {
    return Data()
  }

  static func deserializeDocument(from data: Data) throws -> TestDocument {
    return TestDocument()
  }
}
