//
//  ExceptionHandlerTests.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 20-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import XCTest
@testable import DocumentStore

class ExceptionHandlerTests: XCTestCase {

  func testConvertExceptionWithValue() {
    do {
      let value = try convertExceptionToError { true }
      XCTAssertTrue(value)
    } catch {
      XCTFail("Unexpected error")
    }
  }

  func testConvertExceptionWithError() {
    let expectedError = NSError(domain: "TestDomain", code: 42, userInfo: nil)

    do {
      _ = try convertExceptionToError { throw expectedError }
      XCTFail("Expected error")
    } catch {
      XCTAssertEqual(error as NSError, expectedError)
    }
  }

  func testConvertExceptionWithException() {
    let expectedException = NSException(name: NSExceptionName("TestException"), reason: "Testing", userInfo: nil)

    do {
      _ = try convertExceptionToError { expectedException.raise() }
      XCTFail("Expected error")
    } catch let error as ExceptionError {
      XCTAssertEqual(error.exception, expectedException)
    } catch {
      XCTFail("Unexpected error")
    }
  }
}
