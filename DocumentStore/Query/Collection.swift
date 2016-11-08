//
//  Collection.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 04-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

public protocol Collection {
  associatedtype DocumentType: Document

  var predicate: Predicate<DocumentType>? { get }
  var skip: Int { get }
  var limit: Int? { get }

  // MARK: Limiting

  func skip(_ number: Int) -> Self

  func limit(_ number: Int) -> Self

  // MARK: Filtering

  func filter(isIncluded closure: (DocumentType.Type) -> Predicate<DocumentType>) -> Self

  // MARK: Ordering

  func orderBy(_ closure: (DocumentType.Type) -> SortDescriptor<DocumentType>) -> OrderedCollection<DocumentType>
}

public extension Collection {

  // MARK: Filtering

  public func exclude(_ closure: (DocumentType.Type) -> Predicate<DocumentType>) -> Self {
    return filter { !closure($0) }
  }

  // MARK: Fetching

  public func count(in transaction: ReadTransaction) throws -> Int {
    return try transaction.count(self)
  }

  public func array(in transaction: ReadTransaction) throws -> [DocumentType] {
    return try transaction.fetch(self)
  }

  public func first(in transaction: ReadTransaction) throws -> DocumentType? {
    return try limit(1).array(in: transaction).first
  }

  @discardableResult
  public func delete(in transaction: ReadWriteTransaction) throws -> Int {
    return try transaction.delete(self)
  }
}
