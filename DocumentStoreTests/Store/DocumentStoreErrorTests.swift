//
//  DocumentStoreErrorTests.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 13-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import XCTest
@testable import DocumentStore

class DocumentStoreErrorTests: XCTestCase {

  func testErrorKindCodes() {
    XCTAssertEqual(DocumentStoreError.ErrorKind.storeIdentifierInvalid.rawValue, 1, "Changing errornumbers can confuse users")
    XCTAssertEqual(DocumentStoreError.ErrorKind.documentDescriptionInvalid.rawValue, 2, "Changing errornumbers can confuse users")
    XCTAssertEqual(DocumentStoreError.ErrorKind.documentDescriptionNotRegistered.rawValue, 3, "Changing errornumbers can confuse users")
    XCTAssertEqual(DocumentStoreError.ErrorKind.operationFailed.rawValue, 4, "Changing errornumbers can confuse users")
    XCTAssertEqual(DocumentStoreError.ErrorKind.documentDataCorruption.rawValue, 5, "Changing errornumbers can confuse users")
  }

  func testDescription() {
    let innerError = NSError(domain: "TestDomain", code: 42, userInfo: [NSLocalizedDescriptionKey: "InnerDescription"])
    let error = DocumentStoreError(kind: .documentDataCorruption, message: "Message", underlyingError: innerError)
    XCTAssertEqual(error.description, "DocumentStoreError #5: Message - \(innerError)")
  }
}
