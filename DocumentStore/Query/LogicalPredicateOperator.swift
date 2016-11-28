//
//  LogicalPredicateOperator.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 24-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

/// Defines how to combine two or more `Predicate`s.
///
/// - and: Logical AND operation.
/// - or: Logical OR operation.
public enum LogicalPredicateOperator {
  /// Logical AND operation.
  case and

  /// Logical OR operation.
  case or

  var foundationLogicalType: NSCompoundPredicate.LogicalType {
    switch self {
    case .and:
      return .and
    case .or:
      return .or
    }
  }
}
