//
//  Predicate.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 05-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

/// `Predicate` that can be used to filter a `Collection` based on the `Index`es a `Document` has.
public struct Predicate<DocumentType: Document> {
  let predicate: NSPredicate

  init(predicate: NSPredicate) {
    self.predicate = predicate
  }
}

// MARK: Basic `Index` operators

/// Equal operator.
///
/// - Parameters:
///   - left: `Index` on the left side of the comparison
///   - right: `IndexValueType` on the right side of the comparison
/// - Returns: A `Predicate` representing the comparison
public func == <DocumentType, ValueType>(left: Index<DocumentType, ValueType>, right: ValueType) -> Predicate<DocumentType> {
  return Predicate(predicate: NSExpression(forKeyPath: left.identifier) == NSExpression(forConstantValue: right))
}

/// Not equal operator.
///
/// - Parameters:
///   - left: `Index` on the left side of the comparison
///   - right: `IndexValueType` on the right side of the comparison
/// - Returns: A `Predicate` representing the comparison
public func != <DocumentType, ValueType>(left: Index<DocumentType, ValueType>, right: ValueType) -> Predicate<DocumentType> {
  return Predicate(predicate: NSExpression(forKeyPath: left.identifier) != NSExpression(forConstantValue: right))
}

/// Greater than operator.
///
/// - Note: Will work on all indices, even on for example strings.
///
/// - Parameters:
///   - left: `Index` on the left side of the comparison
///   - right: `IndexValueType` on the right side of the comparison
/// - Returns: A `Predicate` representing the comparison
public func > <DocumentType, ValueType>(left: Index<DocumentType, ValueType>, right: ValueType) -> Predicate<DocumentType> {
  return Predicate(predicate: NSExpression(forKeyPath: left.identifier) > NSExpression(forConstantValue: right))
}

/// Greater than or equal operator.
///
/// - Note: Will work on all indices, even on for example strings.
///
/// - Parameters:
///   - left: `Index` on the left side of the comparison
///   - right: `IndexValueType` on the right side of the comparison
/// - Returns: A `Predicate` representing the comparison
public func >= <DocumentType, ValueType>(left: Index<DocumentType, ValueType>, right: ValueType) -> Predicate<DocumentType> {
  return Predicate(predicate: NSExpression(forKeyPath: left.identifier) >= NSExpression(forConstantValue: right))
}

/// Less than operator.
///
/// - Note: Will work on all indices, even on for example strings.
///
/// - Parameters:
///   - left: `Index` on the left side of the comparison
///   - right: `IndexValueType` on the right side of the comparison
/// - Returns: A `Predicate` representing the comparison
public func < <DocumentType, ValueType>(left: Index<DocumentType, ValueType>, right: ValueType) -> Predicate<DocumentType> {
  return Predicate(predicate: NSExpression(forKeyPath: left.identifier) < NSExpression(forConstantValue: right))
}

/// Less than or equal operator.
///
/// - Note: Will work on all indices, even on for example strings.
///
/// - Parameters:
///   - left: `Index` on the left side of the comparison
///   - right: `IndexValueType` on the right side of the comparison
/// - Returns: A `Predicate` representing the comparison
public func <= <DocumentType, ValueType>(left: Index<DocumentType, ValueType>, right: ValueType) -> Predicate<DocumentType> {
  return Predicate(predicate: NSExpression(forKeyPath: left.identifier) <= NSExpression(forConstantValue: right))
}

/// Like operator, similar in behavior to SQL LIKE.
///
/// - Note: ? and * are allowed as wildcard characters, where ? matches 1 character and * matches 0 
///         or more characters.
///
/// - Parameters:
///   - left: `Index<String>` on the left side of the comparison
///   - right: `String` on the right side of the comparison
/// - Returns: A `Predicate` representing the comparison
public func ~= <DocumentType>(left: Index<DocumentType, String>, right: String) -> Predicate<DocumentType> {
  return Predicate(predicate: NSExpression(forKeyPath: left.identifier) ~= NSExpression(forConstantValue: right))
}

// MARK: Predicate modifiers

/// Negates the `Predicate`.
///
/// - Parameter predicate: `Predicate` to negate.
/// - Returns: A `Predicate` that is negated.
prefix public func ! <DocumentType>(predicate: Predicate<DocumentType>) -> Predicate<DocumentType> {
  let predicate = NSCompoundPredicate(type: .not, subpredicates: [predicate.predicate])
  return Predicate(predicate: predicate)
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

  let predicate = NSCompoundPredicate(type: .and, subpredicates: [left.predicate, right.predicate])
  return Predicate(predicate: predicate)
}

/// Combine two `Predicate`s using a logical 'or' operator
///
/// - Parameters:
///   - left: `Predicate` on the left side
///   - right: `Predicate` on the right side
/// - Returns: New `Predicate` that requires one of the predicates to be true
public func || <DocumentType>(left: Predicate<DocumentType>, right: Predicate<DocumentType>) -> Predicate<DocumentType> {
  let predicate = NSCompoundPredicate(type: .or, subpredicates: [left.predicate, right.predicate])
  return Predicate(predicate: predicate)
}
