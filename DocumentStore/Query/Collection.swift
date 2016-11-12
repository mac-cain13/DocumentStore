//
//  Collection.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 12-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

/// Alias solely for testing
typealias DocumentStoreCollection = Collection

protocol Collection {
  associatedtype DocumentType: Document

  var predicate: Predicate<DocumentType>? { get set }
  var skip: UInt { get set }
  var limit: UInt? { get set }
}

extension Collection {

  // MARK: Limiting

  public func skipping(upTo numberOfItems: UInt) -> Self {
    var collection = self
    collection.skip = skip + numberOfItems
    return collection
  }

  public func limiting(upTo numberOfItems: UInt) -> Self {
    assert(numberOfItems > 0, "Number of items to limit to must be greater than zero.")

    var collection = self
    collection.limit = min(limit ?? UInt.max, numberOfItems)
    return collection
  }

  // MARK: Filtering

  public func filtering(_ isIncluded: (DocumentType.Type) -> Predicate<DocumentType>) -> Self {
    var collection = self
    collection.predicate = collection.predicate && isIncluded(DocumentType.self)
    return collection
  }

  public func excluding(_ closure: (DocumentType.Type) -> Predicate<DocumentType>) -> Self {
    return filtering { !closure($0) }
  }

  // MARK: Ordering

  public func ordered(by sortDescriptor: (DocumentType.Type) -> SortDescriptor<DocumentType>) -> OrderedCollection<DocumentType> {
    return OrderedCollection(collection: self, sortDescriptors: [sortDescriptor(DocumentType.self)])
  }

  // MARK: Fetching

  public func count(in transaction: ReadTransaction) throws -> Int {
    return try transaction.count(self)
  }

  public func array(in transaction: ReadTransaction) throws -> [DocumentType] {
    return try transaction.fetch(self)
  }

  public func first(in transaction: ReadTransaction) throws -> DocumentType? {
    return try limiting(upTo: 1).array(in: transaction).first
  }

  @discardableResult
  public func delete(in transaction: ReadWriteTransaction) throws -> Int {
    return try transaction.delete(self)
  }
}
