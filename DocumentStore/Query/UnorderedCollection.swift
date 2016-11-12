//
//  UnorderedCollection.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 08-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

public struct UnorderedCollection<Type: Document>: Collection {
  public typealias DocumentType = Type

  internal(set) public var predicate: Predicate<DocumentType>?
  internal(set) public var skip: UInt
  internal(set) public var limit: UInt?

  init() {
    self.predicate = nil
    self.skip = 0
    self.limit = nil
  }
}
