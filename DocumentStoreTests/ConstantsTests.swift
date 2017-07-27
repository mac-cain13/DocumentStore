//
//  ConstantsTests.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 07-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import XCTest
@testable import DocumentStore

class ConstantsTests: XCTestCase {

  func testDocumentDataAttributeName() {
    XCTAssertEqual(
      DocumentDataAttributeName,
      "_DocumentStore.documentData",
      "Unexpected constant values, changing constants will break existing users DocumentStores!"
    )
  }

  func testDocumentIdentifierAttributeName() {
    XCTAssertEqual(
      DocumentIdentifierAttributeName,
      "_DocumentStore.documentIdentifier",
      "Unexpected constant values, changing constants will break existing users DocumentStores!"
    )
  }
}
