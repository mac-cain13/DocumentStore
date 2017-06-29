//
//  Predicate.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 05-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

/// `Predicate` that can be used to filter `Document`s using a `Query`.
public struct Predicate<DocumentType: Document> {
  let foundationPredicate: NSPredicate

  /// Create a `Predicate` by combining two `Expression`s.
  ///
  /// - Parameters:
  ///   - left: `Expression` on the left hand side of the operator
  ///   - right: `Expression` on the right hand side of the operator
  ///   - comparisonOperator: Operator to use for the comparison
  public init<ValueType>(left: Expression<DocumentType, ValueType>, right: Expression<DocumentType, ValueType>, comparisonOperator: ExpressionComparisonOperator) {
    foundationPredicate = NSComparisonPredicate(leftExpression: left.foundationExpression, rightExpression: right.foundationExpression, modifier: .direct, type: comparisonOperator.foundationOperator)
  }

  /// Combines the given `Predicate`s using the given `LogicalPredicateOperator`.
  ///
  /// - Note: The `and` operator will always be `true` if no subpredicates are given. The `or`
  ///         `or` operator will always be `false` if no subpredicates are given.
  ///
  /// - Parameters:
  ///   - logicalOperator: The `LogicalPredicateOperator` to use
  ///   - subpredicates: `Predicate`s to combine
  public init(logicalOperator: LogicalPredicateOperator, subpredicates: [Predicate<DocumentType>]) {
    foundationPredicate = NSCompoundPredicate(type: logicalOperator.foundationLogicalType, subpredicates: subpredicates.map { $0.foundationPredicate })
  }

  /// Negates the given `Predicate`.
  ///
  /// - Parameter predicate: `Predicate` to negate
  public init(negate predicate: Predicate<DocumentType>) {
    foundationPredicate = NSCompoundPredicate(type: .not, subpredicates: [predicate.foundationPredicate])
  }
}

// MARK: Predicate modifiers

/// Negates the `Predicate`.
///
/// - Parameter predicate: `Predicate` to negate.
/// - Returns: A `Predicate` that is negated.
prefix public func ! <DocumentType>(predicate: Predicate<DocumentType>) -> Predicate<DocumentType> {
  return Predicate(negate: predicate)
}

// MARK: Predicate combinators

/// Combine two `Predicate`s using a logical 'and' operator
///
/// - Parameters:
///   - left: Optional `Predicate` on the left side, if none given will act like it's always `true`
///   - right: `Predicate` on the right side
/// - Returns: New `Predicate` that requires both predicates to be true
public func && <DocumentType>(left: Predicate<DocumentType>?, right: Predicate<DocumentType>) -> Predicate<DocumentType> {
  guard let left = left else {
    return right
  }

  return Predicate(logicalOperator: .and, subpredicates: [left, right])
}

/// Combine two `Predicate`s using a logical 'or' operator
///
/// - Parameters:
///   - left: `Predicate` on the left side
///   - right: `Predicate` on the right side
/// - Returns: New `Predicate` that requires one of the predicates to be true
public func || <DocumentType>(left: Predicate<DocumentType>, right: Predicate<DocumentType>) -> Predicate<DocumentType> {
  return Predicate(logicalOperator: .or, subpredicates: [left, right])
}
