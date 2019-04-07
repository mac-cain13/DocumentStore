//
//  MockLogger.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 07-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation
@testable import DocumentStore

class MockLogger: Logger {
  struct LogMessage: Equatable {
    let level: LogLevel
    let message: String

    static func == (lhs: LogMessage, rhs: LogMessage) -> Bool {
      return lhs.level == rhs.level && lhs.message == rhs.message
    }
  }

  private(set) var loggedMessages: [LogMessage] = []
  var logCallback: ((LogMessage) -> Void)?

  func log(level: LogLevel, message: String) {
    let logMessage = LogMessage(level: level, message: message)
    loggedMessages.append(logMessage)
    logCallback?(logMessage)
  }
}
