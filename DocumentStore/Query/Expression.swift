//
//  Expression.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 05-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

private func directComparisonPredicate(left: NSExpression, right: NSExpression, type: NSComparisonPredicate.Operator) -> NSPredicate {
  return NSComparisonPredicate(leftExpression: left, rightExpression: right, modifier: .direct, type: type, options: .init(rawValue: 0))
}

func == (left: NSExpression, right: NSExpression) -> NSPredicate {
  return directComparisonPredicate(left: left, right: right, type: .equalTo)
}

func != (left: NSExpression, right: NSExpression) -> NSPredicate {
  return directComparisonPredicate(left: left, right: right, type: .notEqualTo)
}

func > (left: NSExpression, right: NSExpression) -> NSPredicate {
  return directComparisonPredicate(left: left, right: right, type: .greaterThan)
}

func >= (left: NSExpression, right: NSExpression) -> NSPredicate {
  return directComparisonPredicate(left: left, right: right, type: .greaterThanOrEqualTo)
}

func < (left: NSExpression, right: NSExpression) -> NSPredicate {
  return directComparisonPredicate(left: left, right: right, type: .lessThan)
}

func <= (left: NSExpression, right: NSExpression) -> NSPredicate {
  return directComparisonPredicate(left: left, right: right, type: .lessThanOrEqualTo)
}

/// Like operator, similar in behavior to SQL LIKE.
///
/// Notes: ? and * are allowed as wildcard characters, where ? matches 1 character and * matches 0 or more characters.
///
/// - Parameters:
///   - left: Expression on the left side of the comparison
///   - right: Expression on the right side of the comparison
/// - Returns: A `NSPredicate` representing the comparison
func ~= (left: NSExpression, right: NSExpression) -> NSPredicate {
  return directComparisonPredicate(left: left, right: right, type: .like)
}
