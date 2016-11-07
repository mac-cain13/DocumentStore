//
//  NoLogger.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 07-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

final class NoLogger: Logger {
  func log(level: LogLevel, message: String) {}
}
