//
//  UnorderedCollection.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 08-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

/// An `UnorderedCollection` of a single type of `Document`s that can be filtered and ordered.
public struct UnorderedCollection<DocumentType: Document>: Collection {

  var predicate: Predicate<DocumentType>?
  var skip: UInt
  var limit: UInt?

  init() {
    self.predicate = nil
    self.skip = 0
    self.limit = nil
  }
}
