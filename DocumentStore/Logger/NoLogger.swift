//
//  NoLogger.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 07-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

final public class NoLogger: Logger {
  public init() {}

  public func log(level: LogLevel, message: String) {}
}
