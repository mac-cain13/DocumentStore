//
//  UnorderedCollection.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 08-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

protocol UnorderedCollectionType: Collection {
  var predicate: Predicate<DocumentType>? { get set }
  var skip: Int { get set }
  var limit: Int? { get set }
}

extension UnorderedCollectionType {

  // MARK: Limiting

  public func skip(_ number: Int) -> Self {
    var collection = self
    collection.skip = skip + number
    return collection
  }

  public func limit(_ number: Int) -> Self {
    var collection = self
    collection.limit = number
    return collection
  }

  // MARK: Filtering

  public func filter(isIncluded closure: (DocumentType.Type) -> Predicate<DocumentType>) -> Self {
    var collection = self
    collection.predicate = collection.predicate && closure(DocumentType.self)
    return collection
  }

  // MARK: Ordering

  public func orderBy(_ closure: (DocumentType.Type) -> SortDescriptor<DocumentType>) -> OrderedCollection<DocumentType> {
    return OrderedCollection(collection: self, sortDescriptors: [closure(DocumentType.self)])
  }
}

public struct UnorderedCollection<Type: Document>: UnorderedCollectionType {
  public typealias DocumentType = Type

  internal(set) public var predicate: Predicate<DocumentType>?
  internal(set) public var skip: Int
  internal(set) public var limit: Int?

  init() {
    self.predicate = nil
    self.skip = 0
    self.limit = nil
  }
}
