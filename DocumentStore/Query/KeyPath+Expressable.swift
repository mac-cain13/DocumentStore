//
//  KeyPath+Expressable.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 03-07-17.
//  Copyright © 2017 Mathijs Kadijk. All rights reserved.
//

import Foundation

// MARK: Compare `Expressable`s to `KeyPath`s

/// Equal operator.
///
/// - Warning: Using a `KeyPath` that is not an `Index` for the related `Document` will result in
///            a fatal error.
///
/// - Parameters:
///   - left: `Expressable` on the left side of the comparison
///   - right: `KeyPath` on the right side of the comparison
/// - Returns: A `Predicate` representing the comparison
public func == <LeftExpressable: Expressable, Root, Value>(left: LeftExpressable, right: KeyPath<Root, Value>) -> Predicate<LeftExpressable.DocumentType>
  where LeftExpressable.DocumentType == Root, LeftExpressable.ValueType == Value {
    return Predicate(left: left.expression, right: right.expressionOrFatalError, comparisonOperator: .equalTo)
}

/// Not equal operator.
///
/// - Warning: Using a `KeyPath` that is not an `Index` for the related `Document` will result in
///            a fatal error.
///
/// - Parameters:
///   - left: `Expressable` on the left side of the comparison
///   - right: `KeyPath` on the right side of the comparison
/// - Returns: A `Predicate` representing the comparison
public func != <LeftExpressable: Expressable, Root, Value>(left: LeftExpressable, right: KeyPath<Root, Value>) -> Predicate<LeftExpressable.DocumentType>
  where LeftExpressable.DocumentType == Root, LeftExpressable.ValueType == Value {
    return Predicate(left: left.expression, right: right.expressionOrFatalError, comparisonOperator: .notEqualTo)
}

/// Greater than operator.
///
/// - Warning: Using a `KeyPath` that is not an `Index` for the related `Document` will result in
///            a fatal error.
///
/// - Note: Will work on all types, even on for example strings.
///
/// - Parameters:
///   - left: `Expressable` on the left side of the comparison
///   - right: `KeyPath` on the right side of the comparison
/// - Returns: A `Predicate` representing the comparison
public func > <LeftExpressable: Expressable, Root, Value>(left: LeftExpressable, right: KeyPath<Root, Value>) -> Predicate<LeftExpressable.DocumentType>
  where LeftExpressable.DocumentType == Root, LeftExpressable.ValueType == Value {
    return Predicate(left: left.expression, right: right.expressionOrFatalError, comparisonOperator: .greaterThan)
}

/// Greater than or equal operator.
///
/// - Warning: Using a `KeyPath` that is not an `Index` for the related `Document` will result in
///            a fatal error.
///
/// - Note: Will work on all types, even on for example strings.
///
/// - Parameters:
///   - left: `Expressable` on the left side of the comparison
///   - right: `KeyPath` on the right side of the comparison
/// - Returns: A `Predicate` representing the comparison
public func >= <LeftExpressable: Expressable, Root, Value>(left: LeftExpressable, right: KeyPath<Root, Value>) -> Predicate<LeftExpressable.DocumentType>
  where LeftExpressable.DocumentType == Root, LeftExpressable.ValueType == Value {
    return Predicate(left: left.expression, right: right.expressionOrFatalError, comparisonOperator: .greaterThanOrEqualTo)
}

/// Less than operator.
///
/// - Warning: Using a `KeyPath` that is not an `Index` for the related `Document` will result in
///            a fatal error.
///
/// - Note: Will work on all types, even on for example strings.
///
/// - Parameters:
///   - left: `Expressable` on the left side of the comparison
///   - right: `KeyPath` on the right side of the comparison
/// - Returns: A `Predicate` representing the comparison
public func < <LeftExpressable: Expressable, Root, Value>(left: LeftExpressable, right: KeyPath<Root, Value>) -> Predicate<LeftExpressable.DocumentType>
  where LeftExpressable.DocumentType == Root, LeftExpressable.ValueType == Value {
    return Predicate(left: left.expression, right: right.expressionOrFatalError, comparisonOperator: .lessThan)
}

/// Less than or equal operator.
///
/// - Warning: Using a `KeyPath` that is not an `Index` for the related `Document` will result in
///            a fatal error.
///
/// - Note: Will work on all types, even on for example strings.
///
/// - Parameters:
///   - left: `Index` on the left side of the comparison
///   - right: `KeyPath` on the right side of the comparison
/// - Returns: A `Predicate` representing the comparison
public func <= <LeftExpressable: Expressable, Root, Value>(left: LeftExpressable, right: KeyPath<Root, Value>) -> Predicate<LeftExpressable.DocumentType>
  where LeftExpressable.DocumentType == Root, LeftExpressable.ValueType == Value {
    return Predicate(left: left.expression, right: right.expressionOrFatalError, comparisonOperator: .lessThanOrEqualTo)
}
