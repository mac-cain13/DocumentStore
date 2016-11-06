//
//  Query.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 04-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

public struct Query<DocumentType: Document> {
  private(set) var sortDescriptors: [NSSortDescriptor]
  private(set) var predicate: NSPredicate?
  private(set) var skip: Int
  private(set) var limit: Int?

  init() {
    self.sortDescriptors = []
    self.predicate = nil
    self.skip = 0
    self.limit = nil
  }

  // MARK: Limiting

  public func skip(_ number: Int) -> Query<DocumentType> {
    var query = self
    query.skip = skip + number
    return query
  }

  public func limit(_ number: Int) -> Query<DocumentType> {
    var query = self
    query.limit = number
    return query
  }

  // MARK: Filtering

  public func filter(_ closure: (DocumentType.Type) -> Predicate<DocumentType>) -> Query<DocumentType> {
    let predicate = closure(DocumentType.self).predicate

    var query = self
    query.predicate = query.predicate.map { NSCompoundPredicate(type: .and, subpredicates: [$0, predicate]) } ?? predicate
    return query
  }

  public func exclude(_ closure: (DocumentType.Type) -> Predicate<DocumentType>) -> Query<DocumentType> {
    return filter { !closure($0) }
  }

  // MARK: Sorting

  public func orderBy(_ closure: (DocumentType.Type) -> [SortDescriptor<DocumentType>]) -> Query<DocumentType> {
    let sortDescriptors = closure(DocumentType.self).map { $0.sortDescriptor }

    var query = self
    query.sortDescriptors = sortDescriptors
    return query
  }

  public func orderBy(_ closure: (DocumentType.Type) -> SortDescriptor<DocumentType>) -> Query<DocumentType> {
    return orderBy { [closure($0)] }
  }

  // MARK: Fetching

  public func count(in transaction: ReadTransaction) throws -> Int {
    return try transaction.count(matching: self)
  }

  public func all(in transaction: ReadTransaction) throws -> [DocumentType] {
    return try transaction.fetch(matching: self)
  }

  public func first(in transaction: ReadTransaction) throws -> DocumentType? {
    return try limit(1).all(in: transaction).first
  }

  @discardableResult
  public func delete(in transaction: ReadWriteTransaction) throws -> Int {
    return try transaction.delete(matching: self)
  }
}
