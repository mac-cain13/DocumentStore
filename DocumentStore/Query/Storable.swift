//
//  Storable.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 24-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

public protocol Storable {
  associatedtype DocumentType: Document
  associatedtype ValueType: StorableValue

  var storageInformation: StorageInformation<DocumentType, ValueType> { get }
  var resolver: (DocumentType) -> ValueType { get }
}

private extension Storable {
  var expression: Expression<DocumentType, ValueType> {
    return Expression(forStorageInformation: storageInformation)
  }
}

// MARK: Compare `Storable`s to each other

/// Equal operator.
///
/// - Parameters:
///   - left: `Storable` on the left side of the comparison
///   - right: `Storable` on the right side of the comparison
/// - Returns: A `Predicate` representing the comparison
public func == <LeftStorable: Storable, RightStorable: Storable>(left: LeftStorable, right: RightStorable) -> Predicate<LeftStorable.DocumentType>
  where LeftStorable.DocumentType == RightStorable.DocumentType, LeftStorable.ValueType == RightStorable.ValueType {
    return Predicate(left: left.expression, right: right.expression, comparisonOperator: .equalTo)
}

/// Not equal operator.
///
/// - Parameters:
///   - left: `Storable` on the left side of the comparison
///   - right: `Storable` on the right side of the comparison
/// - Returns: A `Predicate` representing the comparison
public func != <LeftStorable: Storable, RightStorable: Storable>(left: LeftStorable, right: RightStorable) -> Predicate<LeftStorable.DocumentType>
  where LeftStorable.DocumentType == RightStorable.DocumentType, LeftStorable.ValueType == RightStorable.ValueType {
    return Predicate(left: left.expression, right: right.expression, comparisonOperator: .notEqualTo)
}

/// Greater than operator.
///
/// - Note: Will work on all `Storable`s, even on for example strings.
///
/// - Parameters:
///   - left: `Storable` on the left side of the comparison
///   - right: `Storable` on the right side of the comparison
/// - Returns: A `Predicate` representing the comparison
public func > <LeftStorable: Storable, RightStorable: Storable>(left: LeftStorable, right: RightStorable) -> Predicate<LeftStorable.DocumentType>
  where LeftStorable.DocumentType == RightStorable.DocumentType, LeftStorable.ValueType == RightStorable.ValueType {
    return Predicate(left: left.expression, right: right.expression, comparisonOperator: .greaterThan)
}

/// Greater than or equal operator.
///
/// - Note: Will work on all `Storable`s, even on for example strings.
///
/// - Parameters:
///   - left: `Storable` on the left side of the comparison
///   - right: `Storable` on the right side of the comparison
/// - Returns: A `Predicate` representing the comparison
public func >= <LeftStorable: Storable, RightStorable: Storable>(left: LeftStorable, right: RightStorable) -> Predicate<LeftStorable.DocumentType>
  where LeftStorable.DocumentType == RightStorable.DocumentType, LeftStorable.ValueType == RightStorable.ValueType {
    return Predicate(left: left.expression, right: right.expression, comparisonOperator: .greaterThanOrEqualTo)
}

/// Less than operator.
///
/// - Note: Will work on all `Storable`s, even on for example strings.
///
/// - Parameters:
///   - left: `Storable` on the left side of the comparison
///   - right: `Storable` on the right side of the comparison
/// - Returns: A `Predicate` representing the comparison
public func < <LeftStorable: Storable, RightStorable: Storable>(left: LeftStorable, right: RightStorable) -> Predicate<LeftStorable.DocumentType>
  where LeftStorable.DocumentType == RightStorable.DocumentType, LeftStorable.ValueType == RightStorable.ValueType {
    return Predicate(left: left.expression, right: right.expression, comparisonOperator: .lessThan)
}

/// Less than or equal operator.
///
/// - Note: Will work on all `Storable`s, even on for example strings.
///
/// - Parameters:
///   - left: `Index` on the left side of the comparison
///   - right: `StorableValue` on the right side of the comparison
/// - Returns: A `Predicate` representing the comparison
public func <= <LeftStorable: Storable, RightStorable: Storable>(left: LeftStorable, right: RightStorable) -> Predicate<LeftStorable.DocumentType>
  where LeftStorable.DocumentType == RightStorable.DocumentType, LeftStorable.ValueType == RightStorable.ValueType {
    return Predicate(left: left.expression, right: right.expression, comparisonOperator: .lessThanOrEqualTo)
}

// MARK: Compare `Storable`s to constant values

/// Equal operator.
///
/// - Parameters:
///   - left: `Storable` on the left side of the comparison
///   - right: `ValueType` on the right side of the comparison
/// - Returns: A `Predicate` representing the comparison
public func == <StorableType: Storable, ValueType>(left: StorableType, right: ValueType) -> Predicate<StorableType.DocumentType>where StorableType.ValueType == ValueType {
    let rightExpression = Expression<StorableType.DocumentType, ValueType>(forConstantValue: right)
    return Predicate(left: left.expression, right: rightExpression, comparisonOperator: .equalTo)
}

/// Not equal operator.
///
/// - Parameters:
///   - left: `Storable` on the left side of the comparison
///   - right: `ValueType` on the right side of the comparison
/// - Returns: A `Predicate` representing the comparison
public func != <StorableType: Storable, ValueType>(left: StorableType, right: ValueType) -> Predicate<StorableType.DocumentType> where StorableType.ValueType == ValueType {
    let rightExpression = Expression<StorableType.DocumentType, ValueType>(forConstantValue: right)
    return Predicate(left: left.expression, right: rightExpression, comparisonOperator: .notEqualTo)
}

/// Greater than operator.
///
/// - Note: Will work on all `Storable`s, even on for example strings.
///
/// - Parameters:
///   - left: `Storable` on the left side of the comparison
///   - right: `ValueType` on the right side of the comparison
/// - Returns: A `Predicate` representing the comparison
public func > <StorableType: Storable, ValueType>(left: StorableType, right: ValueType) -> Predicate<StorableType.DocumentType> where StorableType.ValueType == ValueType {
    let rightExpression = Expression<StorableType.DocumentType, ValueType>(forConstantValue: right)
    return Predicate(left: left.expression, right: rightExpression, comparisonOperator: .greaterThan)
}

/// Greater than or equal operator.
///
/// - Note: Will work on all `Storable`s, even on for example strings.
///
/// - Parameters:
///   - left: `Storable` on the left side of the comparison
///   - right: `ValueType` on the right side of the comparison
/// - Returns: A `Predicate` representing the comparison
public func >= <StorableType: Storable, ValueType>(left: StorableType, right: ValueType) -> Predicate<StorableType.DocumentType> where StorableType.ValueType == ValueType {
    let rightExpression = Expression<StorableType.DocumentType, ValueType>(forConstantValue: right)
    return Predicate(left: left.expression, right: rightExpression, comparisonOperator: .greaterThanOrEqualTo)
}

/// Less than operator.
///
/// - Note: Will work on all `Storable`s, even on for example strings.
///
/// - Parameters:
///   - left: `Storable` on the left side of the comparison
///   - right: `ValueType` on the right side of the comparison
/// - Returns: A `Predicate` representing the comparison
public func < <StorableType: Storable, ValueType>(left: StorableType, right: ValueType) -> Predicate<StorableType.DocumentType> where StorableType.ValueType == ValueType {
    let rightExpression = Expression<StorableType.DocumentType, ValueType>(forConstantValue: right)
    return Predicate(left: left.expression, right: rightExpression, comparisonOperator: .lessThan)
}

/// Less than or equal operator.
///
/// - Note: Will work on all `Storable`s, even on for example strings.
///
/// - Parameters:
///   - left: `Storable` on the left side of the comparison
///   - right: `ValueType` on the right side of the comparison
/// - Returns: A `Predicate` representing the comparison
public func <= <StorableType: Storable, ValueType>(left: StorableType, right: ValueType) -> Predicate<StorableType.DocumentType> where StorableType.ValueType == ValueType {
    let rightExpression = Expression<StorableType.DocumentType, ValueType>(forConstantValue: right)
    return Predicate(left: left.expression, right: rightExpression, comparisonOperator: .lessThanOrEqualTo)
}

/// Like operator, similar in behavior to SQL LIKE.
///
/// - Note: ? and * are allowed as wildcard characters, where ? matches 1 character and * matches 0
///         or more characters.
///
/// - Parameters:
///   - left: `Storable` on the left side of the comparison
///   - right: Like pattern on the right side of the comparison
/// - Returns: A `Predicate` representing the comparison
public func ~= <StorableType: Storable>(left: StorableType, right: String) -> Predicate<StorableType.DocumentType> where StorableType.ValueType == String {
    let rightExpression = Expression<StorableType.DocumentType, String>(forConstantValue: right)
    return Predicate(left: left.expression, right: rightExpression, comparisonOperator: .like)
}

/// Equates the `Storable` to false.
///
/// - Parameter storable: `Storable` to check for the value false
/// - Returns: A `Predicate` representing the comparison
prefix public func ! <StorableType: Storable>(storable: StorableType) -> Predicate<StorableType.DocumentType> where StorableType.ValueType == Bool {
    let rightExpression = Expression<StorableType.DocumentType, Bool>(forConstantValue: false)
    return Predicate(left: storable.expression, right: rightExpression, comparisonOperator: .equalTo)
}
