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

  private let left = NSExpression(forKeyPath: TestDocument.isTest.storageInformation.propertyName.keyPath)
  private let right = NSExpression(forConstantValue: false)

  private func foundationPredicate(operator type: NSComparisonPredicate.Operator, left: NSExpression? = nil, right: NSExpression? = nil) -> NSPredicate {
    let left = left ?? self.left
    let right = right ?? self.right
    return NSComparisonPredicate(leftExpression: left, rightExpression: right, modifier: .direct, type: type)
  }

  func testCompareInitializer() {
    let left = Expression<TestDocument, Bool>(forConstantValue: false)
    let right = Expression<TestDocument, Bool>(forConstantValue: true)
    let predicate = Predicate<TestDocument>(left: left, right: right, comparisonOperator: .equalTo)

    let foundationPredicate = self.foundationPredicate(operator: .equalTo, left: left.foundationExpression, right: right.foundationExpression)
    XCTAssertEqual(predicate.foundationPredicate, foundationPredicate)
  }

  func testCombinationInitializer() {
    let predicateA = (TestDocument.isTest == false)
    let predicateB = (TestDocument.isTest == true)
    let predicate = Predicate<TestDocument>(logicalOperator: .and, subpredicates: [predicateA, predicateB])

    let foundationPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateA.foundationPredicate, predicateB.foundationPredicate])
    XCTAssertEqual(predicate.foundationPredicate, foundationPredicate)
  }

  func testNegateInitializer() {
    let predicate = (TestDocument.isTest == false)
    let negatedPredicate = Predicate(negate: predicate)
    XCTAssertEqual(negatedPredicate.foundationPredicate, NSCompoundPredicate(notPredicateWithSubpredicate: predicate.foundationPredicate))
  }

  // MARK: Basic predicate operators

  func testEquals() {
    let predicate = (TestDocument.isTest == false).foundationPredicate
    XCTAssertEqual(predicate, foundationPredicate(operator: .equalTo))
  }

  func testNotEqualTo() {
    let predicate = (TestDocument.isTest != false).foundationPredicate
    XCTAssertEqual(predicate, foundationPredicate(operator: .notEqualTo))
  }

  func testGreaterThan() {
    let predicate = (TestDocument.isTest > false).foundationPredicate
    XCTAssertEqual(predicate, foundationPredicate(operator: .greaterThan))
  }

  func testGreaterThanOrEqualTo() {
    let predicate = (TestDocument.isTest >= false).foundationPredicate
    XCTAssertEqual(predicate, foundationPredicate(operator: .greaterThanOrEqualTo))
  }

  func testLessThan() {
    let predicate = (TestDocument.isTest < false).foundationPredicate
    XCTAssertEqual(predicate, foundationPredicate(operator: .lessThan))
  }

  func testLessThanOrEqualTo() {
    let predicate = (TestDocument.isTest <= false).foundationPredicate
    XCTAssertEqual(predicate, foundationPredicate(operator: .lessThanOrEqualTo))
  }

  func testLike() {
    let predicate = (TestDocument.isTestString ~= "").foundationPredicate
    XCTAssertEqual(predicate, foundationPredicate(operator: .like, right: NSExpression(forConstantValue: "")))
  }

  // MARK: Predicate modifiers

  func testNot() {
    let predicate = TestDocument.isTest == false
    let notPredicate = !predicate
    XCTAssertEqual(notPredicate.foundationPredicate, NSCompoundPredicate(type: .not, subpredicates: [predicate.foundationPredicate]))
  }

  // MARK: Predicate combinators

  func testAndWithNil() {
    let predicate = TestDocument.isTest == false
    let combinedPredicate = nil && predicate
    XCTAssertEqual(combinedPredicate.foundationPredicate, predicate.foundationPredicate)
  }

  func testAnd() {
    let predicate = TestDocument.isTest == false
    let combinedPredicate = predicate && predicate
    XCTAssertEqual(combinedPredicate.foundationPredicate, NSCompoundPredicate(type: .and, subpredicates: [predicate.foundationPredicate, predicate.foundationPredicate]))
  }

  func testOr() {
    let predicate = TestDocument.isTest == false
    let combinedPredicate = predicate || predicate
    XCTAssertEqual(combinedPredicate.foundationPredicate, NSCompoundPredicate(type: .or, subpredicates: [predicate.foundationPredicate, predicate.foundationPredicate]))
  }
}

private struct TestDocument: Document {
  static let isTest = Index<TestDocument, Bool>(name: "") { _ in false }
  static let isTestString = Index<TestDocument, String>(name: "") { _ in "" }
  static let documentDescriptor = DocumentDescriptor<TestDocument>(name: "", indices: [])

  func serializeDocument() throws -> Data {
    return Data()
  }

  static func deserializeDocument(from data: Data) throws -> TestDocument {
    return TestDocument()
  }
}
