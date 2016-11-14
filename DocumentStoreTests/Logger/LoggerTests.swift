//
//  LoggerTests.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 14-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import XCTest
@testable import DocumentStore
import CoreData

class LoggerTests: XCTestCase {

  func testLogError() {
    let logger = MockLogger()
    let error = NSError(domain: "TestDomain", code: 42, userInfo: [NSLocalizedDescriptionKey: "ErrorDescription"])
    logger.log(level: .debug, message: "Message", error: error)

    XCTAssertEqual(logger.loggedMessages.count, 1)
    XCTAssertEqual(logger.loggedMessages.first?.level, .debug)
    XCTAssertEqual(logger.loggedMessages.first?.message, "Message (\(error))")
  }
}
