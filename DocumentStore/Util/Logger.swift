//
//  Logger.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 05-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

public enum LogLevel {
  case trace
  case debug
  case info
  case warn
  case error
}

public protocol Logger {
  func log(level: LogLevel, message: String)
}

extension Logger {
  func log(level: LogLevel, message: String, error: Error) {
    log(level: level, message: "\(message) (\(error))")
  }
}

class NoLogger: Logger {
  func log(level: LogLevel, message: String) {}
}

class PrintLogger: Logger {
  func log(level: LogLevel, message: String) {
    let logLevelString: String

    switch level {
    case .trace:
      logLevelString = "Trace"
    case .debug:
      logLevelString = "Debug"
    case .info:
      logLevelString = "Info"
    case .warn:
      logLevelString = "Warn"
    case .error:
      logLevelString = "Error"
    }

    debugPrint("[DocumentStore] \(logLevelString): \(message)")
  }
}
