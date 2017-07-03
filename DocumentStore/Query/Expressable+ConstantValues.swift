//
//  Expressable+ConstantValues.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 03-07-17.
//  Copyright © 2017 Mathijs Kadijk. All rights reserved.
//

import Foundation

// MARK: Compare `Expressable`s to constant values

/// Equal operator.
///
/// - Parameters:
///   - left: `Expressable` on the left side of the comparison
///   - right: Value on the right side of the comparison to compare against
/// - Returns: A `Predicate` representing the comparison
public func == <ExpressableType: Expressable, ValueType>(left: ExpressableType, right: ValueType) -> Predicate<ExpressableType.DocumentType>where ExpressableType.ValueType == ValueType {
  let rightExpression = Expression<ExpressableType.DocumentType, ValueType>(forConstantValue: right)
  return Predicate(left: left.expression, right: rightExpression, comparisonOperator: .equalTo)
}

/// Not equal operator.
///
/// - Parameters:
///   - left: `Expressable` on the left side of the comparison
///   - right: Value on the right side of the comparison to compare against
/// - Returns: A `Predicate` representing the comparison
public func != <ExpressableType: Expressable, ValueType>(left: ExpressableType, right: ValueType) -> Predicate<ExpressableType.DocumentType> where ExpressableType.ValueType == ValueType {
  let rightExpression = Expression<ExpressableType.DocumentType, ValueType>(forConstantValue: right)
  return Predicate(left: left.expression, right: rightExpression, comparisonOperator: .notEqualTo)
}

/// Greater than operator.
///
/// - Note: Will work on all `Expressable`s, even on for example strings.
///
/// - Parameters:
///   - left: `Expressable` on the left side of the comparison
///   - right: Value on the right side of the comparison to compare against
/// - Returns: A `Predicate` representing the comparison
public func > <ExpressableType: Expressable, ValueType>(left: ExpressableType, right: ValueType) -> Predicate<ExpressableType.DocumentType> where ExpressableType.ValueType == ValueType {
  let rightExpression = Expression<ExpressableType.DocumentType, ValueType>(forConstantValue: right)
  return Predicate(left: left.expression, right: rightExpression, comparisonOperator: .greaterThan)
}

/// Greater than or equal operator.
///
/// - Note: Will work on all `Expressable`s, even on for example strings.
///
/// - Parameters:
///   - left: `Expressable` on the left side of the comparison
///   - right: Value on the right side of the comparison to compare against
/// - Returns: A `Predicate` representing the comparison
public func >= <ExpressableType: Expressable, ValueType>(left: ExpressableType, right: ValueType) -> Predicate<ExpressableType.DocumentType> where ExpressableType.ValueType == ValueType {
  let rightExpression = Expression<ExpressableType.DocumentType, ValueType>(forConstantValue: right)
  return Predicate(left: left.expression, right: rightExpression, comparisonOperator: .greaterThanOrEqualTo)
}

/// Less than operator.
///
/// - Note: Will work on all `Expressable`s, even on for example strings.
///
/// - Parameters:
///   - left: `Expressable` on the left side of the comparison
///   - right: Value on the right side of the comparison to compare against
/// - Returns: A `Predicate` representing the comparison
public func < <ExpressableType: Expressable, ValueType>(left: ExpressableType, right: ValueType) -> Predicate<ExpressableType.DocumentType> where ExpressableType.ValueType == ValueType {
  let rightExpression = Expression<ExpressableType.DocumentType, ValueType>(forConstantValue: right)
  return Predicate(left: left.expression, right: rightExpression, comparisonOperator: .lessThan)
}

/// Less than or equal operator.
///
/// - Note: Will work on all `Expressable`s, even on for example strings.
///
/// - Parameters:
///   - left: `Expressable` on the left side of the comparison
///   - right: Value on the right side of the comparison to compare against
/// - Returns: A `Predicate` representing the comparison
public func <= <ExpressableType: Expressable, ValueType>(left: ExpressableType, right: ValueType) -> Predicate<ExpressableType.DocumentType> where ExpressableType.ValueType == ValueType {
  let rightExpression = Expression<ExpressableType.DocumentType, ValueType>(forConstantValue: right)
  return Predicate(left: left.expression, right: rightExpression, comparisonOperator: .lessThanOrEqualTo)
}

/// Like operator, similar in behavior to SQL LIKE.
///
/// - Note: ? and * are allowed as wildcard characters, where ? matches 1 character and * matches 0
///         or more characters.
///
/// - Parameters:
///   - left: `Expressable` on the left side of the comparison
///   - right: Like pattern on the right side of the comparison
/// - Returns: A `Predicate` representing the comparison
public func ~= <ExpressableType: Expressable>(left: ExpressableType, right: String) -> Predicate<ExpressableType.DocumentType> where ExpressableType.ValueType == String {
  let rightExpression = Expression<ExpressableType.DocumentType, String>(forConstantValue: right)
  return Predicate(left: left.expression, right: rightExpression, comparisonOperator: .like)
}

/// Equates the `Expressable` to false.
///
/// - Parameter expressable: `Expressable` to check for the value false
/// - Returns: A `Predicate` representing the comparison
prefix public func ! <ExpressableType: Expressable>(expressable: ExpressableType) -> Predicate<ExpressableType.DocumentType> where ExpressableType.ValueType == Bool {
  let rightExpression = Expression<ExpressableType.DocumentType, Bool>(forConstantValue: false)
  return Predicate(left: expressable.expression, right: rightExpression, comparisonOperator: .equalTo)
}
