//
//  Expressable.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 24-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

/// Describes a value that can be expressed as an `Expression` for use in a `Predicate`.
public protocol Expressable {
  associatedtype DocumentType: Document
  associatedtype ValueType: IndexableValue

  var expression: Expression<DocumentType, ValueType> { get }
}

extension Index: Expressable {
  public var expression: Expression<DocumentType, ValueType> {
    return Expression(forIndex: self)
  }
}

extension Identifier: Expressable {
  public var expression: Expression<DocumentType, ValueType> {
    return Expression(forIdentifier: self)
  }
}

// MARK: Compare `Expressable`s to each other

/// Equal operator.
///
/// - Parameters:
///   - left: `Expressable` on the left side of the comparison
///   - right: `Expressable` on the right side of the comparison
/// - Returns: A `Predicate` representing the comparison
public func == <LeftExpressable: Expressable, RightExpressable: Expressable>(left: LeftExpressable, right: RightExpressable) -> Predicate<LeftExpressable.DocumentType>
  where LeftExpressable.DocumentType == RightExpressable.DocumentType, LeftExpressable.ValueType == RightExpressable.ValueType {
    return Predicate(left: left.expression, right: right.expression, comparisonOperator: .equalTo)
}

/// Not equal operator.
///
/// - Parameters:
///   - left: `Expressable` on the left side of the comparison
///   - right: `Expressable` on the right side of the comparison
/// - Returns: A `Predicate` representing the comparison
public func != <LeftExpressable: Expressable, RightExpressable: Expressable>(left: LeftExpressable, right: RightExpressable) -> Predicate<LeftExpressable.DocumentType>
  where LeftExpressable.DocumentType == RightExpressable.DocumentType, LeftExpressable.ValueType == RightExpressable.ValueType {
    return Predicate(left: left.expression, right: right.expression, comparisonOperator: .notEqualTo)
}

/// Greater than operator.
///
/// - Note: Will work on all `Expressable`s, even on for example strings.
///
/// - Parameters:
///   - left: `Expressable` on the left side of the comparison
///   - right: `Expressable` on the right side of the comparison
/// - Returns: A `Predicate` representing the comparison
public func > <LeftExpressable: Expressable, RightExpressable: Expressable>(left: LeftExpressable, right: RightExpressable) -> Predicate<LeftExpressable.DocumentType>
  where LeftExpressable.DocumentType == RightExpressable.DocumentType, LeftExpressable.ValueType == RightExpressable.ValueType {
    return Predicate(left: left.expression, right: right.expression, comparisonOperator: .greaterThan)
}

/// Greater than or equal operator.
///
/// - Note: Will work on all `Expressable`s, even on for example strings.
///
/// - Parameters:
///   - left: `Expressable` on the left side of the comparison
///   - right: `Expressable` on the right side of the comparison
/// - Returns: A `Predicate` representing the comparison
public func >= <LeftExpressable: Expressable, RightExpressable: Expressable>(left: LeftExpressable, right: RightExpressable) -> Predicate<LeftExpressable.DocumentType>
  where LeftExpressable.DocumentType == RightExpressable.DocumentType, LeftExpressable.ValueType == RightExpressable.ValueType {
    return Predicate(left: left.expression, right: right.expression, comparisonOperator: .greaterThanOrEqualTo)
}

/// Less than operator.
///
/// - Note: Will work on all `Expressable`s, even on for example strings.
///
/// - Parameters:
///   - left: `Expressable` on the left side of the comparison
///   - right: `Expressable` on the right side of the comparison
/// - Returns: A `Predicate` representing the comparison
public func < <LeftExpressable: Expressable, RightExpressable: Expressable>(left: LeftExpressable, right: RightExpressable) -> Predicate<LeftExpressable.DocumentType>
  where LeftExpressable.DocumentType == RightExpressable.DocumentType, LeftExpressable.ValueType == RightExpressable.ValueType {
    return Predicate(left: left.expression, right: right.expression, comparisonOperator: .lessThan)
}

/// Less than or equal operator.
///
/// - Note: Will work on all `Expressable`s, even on for example strings.
///
/// - Parameters:
///   - left: `Expressable` on the left side of the comparison
///   - right: `Expressable` on the right side of the comparison
/// - Returns: A `Predicate` representing the comparison
public func <= <LeftExpressable: Expressable, RightExpressable: Expressable>(left: LeftExpressable, right: RightExpressable) -> Predicate<LeftExpressable.DocumentType>
  where LeftExpressable.DocumentType == RightExpressable.DocumentType, LeftExpressable.ValueType == RightExpressable.ValueType {
    return Predicate(left: left.expression, right: right.expression, comparisonOperator: .lessThanOrEqualTo)
}
