//
//  OrderedCollection.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 08-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

public struct OrderedCollection<Type: Document>: UnorderedCollectionType {
  public typealias DocumentType = Type

  internal(set) public var sortDescriptors: [SortDescriptor<DocumentType>]
  internal(set) public var predicate: Predicate<DocumentType>?
  internal(set) public var skip: Int
  internal(set) public var limit: Int?

  init<CollectionType: UnorderedCollectionType>(collection: CollectionType, sortDescriptors: [SortDescriptor<DocumentType>]) where CollectionType.DocumentType == DocumentType {
    self.sortDescriptors = sortDescriptors
    self.predicate = collection.predicate
    self.skip = collection.skip
    self.limit = collection.limit
  }

  public func thenBy(_ closure: (DocumentType.Type) -> SortDescriptor<DocumentType>) -> OrderedCollection<DocumentType> {
    var collection = self
    collection.sortDescriptors.append(closure(DocumentType.self))
    return collection
  }
}
