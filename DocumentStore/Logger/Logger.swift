//
//  Logger.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 05-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

/// Logger that can be used to gather information to debug the `DocumentStore` and operations 
/// performed on it.
public protocol Logger {
  /// Logs a message.
  ///
  /// - Parameters:
  ///   - level: Level that is applicable to the message
  ///   - message: Message to log
  func log(level: LogLevel, message: String)
}

extension Logger {
  func log(level: LogLevel, message: String, error: Error) {
    log(level: level, message: "\(message) (\(error))")
  }
}
