//
//  ExceptionTests.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 20-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import XCTest
@testable import DocumentStore
@testable import ObjCExceptionHandler

class ExceptionTests: XCTestCase {

  func testNoExceptionRaised() {
    let exception = Exception.raised {}
    XCTAssertNil(exception)
  }

  func testExceptionRaised() {
    let expectedException = NSException(name: NSExceptionName("TestException"), reason: "Testing", userInfo: nil)
    let exception = Exception.raised {
      expectedException.raise()
    }
    XCTAssertEqual(exception, expectedException)
  }
}
