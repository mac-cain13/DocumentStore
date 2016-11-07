//
//  Collection.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 04-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

public struct Collection<DocumentType: Document> {
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

  public func skip(_ number: Int) -> Collection<DocumentType> {
    var collection = self
    collection.skip = skip + number
    return collection
  }

  public func limit(_ number: Int) -> Collection<DocumentType> {
    var collection = self
    collection.limit = number
    return collection
  }

  // MARK: Filtering

  public func filter(_ closure: (DocumentType.Type) -> Predicate<DocumentType>) -> Collection<DocumentType> {
    let predicate = closure(DocumentType.self).predicate

    var collection = self
    collection.predicate = collection.predicate.map { NSCompoundPredicate(type: .and, subpredicates: [$0, predicate]) } ?? predicate
    return collection
  }

  public func exclude(_ closure: (DocumentType.Type) -> Predicate<DocumentType>) -> Collection<DocumentType> {
    return filter { !closure($0) }
  }

  // MARK: Sorting

  public func orderBy(_ closure: (DocumentType.Type) -> [SortDescriptor<DocumentType>]) -> Collection<DocumentType> {
    let sortDescriptors = closure(DocumentType.self).map { $0.sortDescriptor }

    var collection = self
    collection.sortDescriptors = sortDescriptors
    return collection
  }

  public func orderBy(_ closure: (DocumentType.Type) -> SortDescriptor<DocumentType>) -> Collection<DocumentType> {
    return orderBy { [closure($0)] }
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
