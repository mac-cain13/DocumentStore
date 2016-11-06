//
//  Predicate.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 05-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

public struct Predicate<DocumentType: Document> {
  let predicate: NSPredicate

  init(predicate: NSPredicate) {
    self.predicate = predicate
  }
}

// MARK: Basic predicate operators

public func == <DocumentType, ValueType>(left: Index<DocumentType, ValueType>, right: ValueType) -> Predicate<DocumentType> {
  return Predicate(predicate: NSExpression(forKeyPath: left.identifier) == NSExpression(forConstantValue: right))
}

public func != <DocumentType, ValueType>(left: Index<DocumentType, ValueType>, right: ValueType) -> Predicate<DocumentType> {
  return Predicate(predicate: NSExpression(forKeyPath: left.identifier) != NSExpression(forConstantValue: right))
}

public func > <DocumentType, ValueType>(left: Index<DocumentType, ValueType>, right: ValueType) -> Predicate<DocumentType> {
  return Predicate(predicate: NSExpression(forKeyPath: left.identifier) > NSExpression(forConstantValue: right))
}

public func >= <DocumentType, ValueType>(left: Index<DocumentType, ValueType>, right: ValueType) -> Predicate<DocumentType> {
  return Predicate(predicate: NSExpression(forKeyPath: left.identifier) >= NSExpression(forConstantValue: right))
}

public func < <DocumentType, ValueType>(left: Index<DocumentType, ValueType>, right: ValueType) -> Predicate<DocumentType> {
  return Predicate(predicate: NSExpression(forKeyPath: left.identifier) > NSExpression(forConstantValue: right))
}

public func <= <DocumentType, ValueType>(left: Index<DocumentType, ValueType>, right: ValueType) -> Predicate<DocumentType> {
  return Predicate(predicate: NSExpression(forKeyPath: left.identifier) <= NSExpression(forConstantValue: right))
}

public func ~= <DocumentType, ValueType>(left: Index<DocumentType, ValueType>, right: ValueType) -> Predicate<DocumentType> {
  return Predicate(predicate: NSExpression(forKeyPath: left.identifier) ~= NSExpression(forConstantValue: right))
}

// MARK: Predicate modifiers

prefix public func ! <DocumentType>(predicate: Predicate<DocumentType>) -> Predicate<DocumentType> {
  let predicate = NSCompoundPredicate(type: .not, subpredicates: [predicate.predicate])
  return Predicate(predicate: predicate)
}

// MARK: Predicate combinators

public func && <DocumentType>(left: Predicate<DocumentType>, right: Predicate<DocumentType>) -> Predicate<DocumentType> {
  let predicate = NSCompoundPredicate(type: .and, subpredicates: [left.predicate, right.predicate])
  return Predicate(predicate: predicate)
}

public func || <DocumentType>(left: Predicate<DocumentType>, right: Predicate<DocumentType>) -> Predicate<DocumentType> {
  let predicate = NSCompoundPredicate(type: .or, subpredicates: [left.predicate, right.predicate])
  return Predicate(predicate: predicate)
}
