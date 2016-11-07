//
//  ValidatableTests.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 07-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import XCTest
@testable import DocumentStore

class ValidatableTests: XCTestCase {

  private struct FixedValidatable: Validatable {
    fileprivate let issues: [ValidationIssue]
    func validate() -> [ValidationIssue] { return issues }
  }

  func testValidatableSequenceReturnsAllIssues() {
    let firstValidatable = FixedValidatable(issues: ["Issue #1.1", "Issue #1.2"])
    let secondValidatable = FixedValidatable(issues: [])
    let thirdValidatable = FixedValidatable(issues: ["Issue #3.1"])

    XCTAssertEqual(
      [firstValidatable, secondValidatable, thirdValidatable].validate(),
      firstValidatable.issues + secondValidatable.issues + thirdValidatable.issues
    )
  }

}
