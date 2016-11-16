//
//  DocumentDeserializationErrorTests.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 16-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import XCTest
@testable import DocumentStore

class DocumentDeserializationErrorTests: XCTestCase {

  func testInitilizer() {
    let resolution = DocumentDeserializationError.Resolution.abortOperation
    let underlyingError = NSError(domain: "TestDomain", code: 42, userInfo: nil)
    let error = DocumentDeserializationError(resolution: resolution, underlyingError: underlyingError)

    XCTAssertEqual(error.resolution, resolution)
    XCTAssertEqual(error.underlyingError as NSError, underlyingError)
  }
}
