//
//  ExpressionComparisonOperator.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 24-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

/// Defines how to compare two `Expression`s.
///
/// - lessThan: <
/// - lessThanOrEqualTo: <=
/// - greaterThan: >
/// - greaterThanOrEqualTo: >=
/// - equalTo: ==
/// - notEqualTo: !=
/// - like: Matches a pattern on a string, similar in behavior to SQL LIKE.
public enum ExpressionComparisonOperator {
  /// <
  case lessThan

  /// <=
  case lessThanOrEqualTo

  /// >
  case greaterThan

  /// >=
  case greaterThanOrEqualTo

  /// ==
  case equalTo

  /// !=
  case notEqualTo

  /// Matches a pattern on a string, similar in behavior to SQL LIKE.
  case like

  var foundationOperator: NSComparisonPredicate.Operator {
    switch self {
    case .lessThan:
      return .lessThan
    case .lessThanOrEqualTo:
      return .lessThanOrEqualTo
    case .greaterThan:
      return .greaterThan
    case .greaterThanOrEqualTo:
      return .greaterThanOrEqualTo
    case .equalTo:
      return .equalTo
    case .notEqualTo:
      return .notEqualTo
    case .like:
      return .like
    }
  }
}
