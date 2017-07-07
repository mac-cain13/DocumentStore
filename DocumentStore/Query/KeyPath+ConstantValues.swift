//
//  KeyPath+ConstantValues.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 07-07-17.
//  Copyright © 2017 Mathijs Kadijk. All rights reserved.
//

import Foundation

// MARK: Compare `KeyPath`s to constant values

/// Equal operator.
///
/// - Warning: Using a `KeyPath` that is not an `Index` for the related `Document` will result in
///            a fatal error.
///
/// - Parameters:
///   - left: `KeyPath` on the left side of the comparison
///   - right: `StorableValue` on the right side of the comparison
/// - Returns: A `Predicate` representing the comparison
public func == <Root, Value>(left: KeyPath<Root, Value>, right: Value) -> Predicate<Root> where Value: IndexableValue {
  let rightExpression = Expression<Root, Value>(forConstantValue: right)
  return Predicate(left: left.expressionOrFatalError, right: rightExpression, comparisonOperator: .equalTo)
}

/// Not equal operator.
///
/// - Warning: Using a `KeyPath` that is not an `Index` for the related `Document` will result in
///            a fatal error.
///
/// - Parameters:
///   - left: `KeyPath` on the left side of the comparison
///   - right: Value on the right side of the comparison to compare against
/// - Returns: A `Predicate` representing the comparison
public func != <Root, Value>(left: KeyPath<Root, Value>, right: Value) -> Predicate<Root> where Value: IndexableValue {
  let rightExpression = Expression<Root, Value>(forConstantValue: right)
  return Predicate(left: left.expressionOrFatalError, right: rightExpression, comparisonOperator: .notEqualTo)
}

/// Greater than operator.
///
/// - Warning: Using a `KeyPath` that is not an `Index` for the related `Document` will result in
///            a fatal error.
///
/// - Note: Will work on all types, even on for example strings.
///
/// - Parameters:
///   - left: `KeyPath` on the left side of the comparison
///   - right: Value on the right side of the comparison to compare against
/// - Returns: A `Predicate` representing the comparison
public func > <Root, Value>(left: KeyPath<Root, Value>, right: Value) -> Predicate<Root> where Value: IndexableValue {
  let rightExpression = Expression<Root, Value>(forConstantValue: right)
  return Predicate(left: left.expressionOrFatalError, right: rightExpression, comparisonOperator: .greaterThan)
}

/// Greater than or equal operator.
///
/// - Warning: Using a `KeyPath` that is not an `Index` for the related `Document` will result in
///            a fatal error.
///
/// - Note: Will work on all types, even on for example strings.
///
/// - Parameters:
///   - left: `KeyPath` on the left side of the comparison
///   - right: Value on the right side of the comparison to compare against
/// - Returns: A `Predicate` representing the comparison
public func >= <Root, Value>(left: KeyPath<Root, Value>, right: Value) -> Predicate<Root> where Value: IndexableValue {
  let rightExpression = Expression<Root, Value>(forConstantValue: right)
  return Predicate(left: left.expressionOrFatalError, right: rightExpression, comparisonOperator: .greaterThanOrEqualTo)
}

/// Less than operator.
///
/// - Warning: Using a `KeyPath` that is not an `Index` for the related `Document` will result in
///            a fatal error.
///
/// - Note: Will work on all types, even on for example strings.
///
/// - Parameters:
///   - left: `KeyPath` on the left side of the comparison
///   - right: Value on the right side of the comparison to compare against
/// - Returns: A `Predicate` representing the comparison
public func < <Root, Value>(left: KeyPath<Root, Value>, right: Value) -> Predicate<Root> where Value: IndexableValue {
  let rightExpression = Expression<Root, Value>(forConstantValue: right)
  return Predicate(left: left.expressionOrFatalError, right: rightExpression, comparisonOperator: .lessThan)
}

/// Less than or equal operator.
///
/// - Warning: Using a `KeyPath` that is not an `Index` for the related `Document` will result in
///            a fatal error.
///
/// - Note: Will work on all types, even on for example strings.
///
/// - Parameters:
///   - left: `KeyPath` on the left side of the comparison
///   - right: Value on the right side of the comparison to compare against
/// - Returns: A `Predicate` representing the comparison
public func <= <Root, Value>(left: KeyPath<Root, Value>, right: Value) -> Predicate<Root> where Value: IndexableValue {
  let rightExpression = Expression<Root, Value>(forConstantValue: right)
  return Predicate(left: left.expressionOrFatalError, right: rightExpression, comparisonOperator: .lessThanOrEqualTo)
}

/// Like operator, similar in behavior to SQL LIKE.
///
/// - Warning: Using a `KeyPath` that is not an `Index` for the related `Document` will result in
///            a fatal error.
///
/// - Note: ? and * are allowed as wildcard characters, where ? matches 1 character and * matches 0
///         or more characters.
///
/// - Parameters:
///   - left: `KeyPath` on the left side of the comparison
///   - right: Like pattern on the right side of the comparison
/// - Returns: A `Predicate` representing the comparison
public func ~= <Root>(left: KeyPath<Root, String>, right: String) -> Predicate<Root> {
  let rightExpression = Expression<Root, String>(forConstantValue: right)
  return Predicate(left: left.expressionOrFatalError, right: rightExpression, comparisonOperator: .like)
}

/// Equates the `KeyPath` to false.
///
/// - Warning: Using a `KeyPath` that is not an `Index` for the related `Document` will result in
///            a fatal error.
///
/// - Parameter keyPath: `KeyPath` to check for the value false
/// - Returns: A `Predicate` representing the comparison
prefix public func ! <Root>(keyPath: KeyPath<Root, Bool>) -> Predicate<Root> {
  let rightExpression = Expression<Root, Bool>(forConstantValue: false)
  return Predicate(left: keyPath.expressionOrFatalError, right: rightExpression, comparisonOperator: .equalTo)
}
