//
//  Logger.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 05-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

public protocol Logger {
  func log(level: LogLevel, message: String)
}

extension Logger {
  func log(level: LogLevel, message: String, error: Error) {
    log(level: level, message: "\(message) (\(error))")
  }
}
