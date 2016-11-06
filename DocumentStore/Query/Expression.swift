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

func ~= (left: NSExpression, right: NSExpression) -> NSPredicate {
  return directComparisonPredicate(left: left, right: right, type: .like)
}
