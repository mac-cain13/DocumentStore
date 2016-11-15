//
//  LogLevel.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 07-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

/// Level to log messages at, can be used to filter on.
///
/// - trace: Status messages at a very detailed level for debugging, may be very high volume
/// - debug: Status messages for debugging, entry/exit of non-trivial routines will be logged
/// - info: Failures that won't have any impact on the user experience or important successful actions
/// - warn: Failure that the store will recover from, but potential strange/inconsistent behaviour in user experience
/// - error: Failure that the store won't recover from itselves, user experience will be affected
public enum LogLevel {
  /// Status messages at a very detailed level for debugging, may be very high volume.
  case trace

  /// Status messages for debugging, entry/exit of non-trivial routines will be logged.
  case debug

  /// Failures that won't have any impact on the user experience or important successful actions.
  case info

  /// Failure that the store will recover from, but potential strange/inconsistent behaviour in user 
  /// experience.
  case warn

  /// Failure that the store won't recover from itselves, user experience will be affected.
  case error
}
