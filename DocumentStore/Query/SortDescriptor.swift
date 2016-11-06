//
//  SortDescriptor.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 05-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

public struct SortDescriptor<DocumentType: Document> {
  let sortDescriptor: NSSortDescriptor

  init(sortDescriptor: NSSortDescriptor) {
    self.sortDescriptor = sortDescriptor
  }
}

// MARK: Index sortdescriptors

public extension Index {
  public func ascending() -> SortDescriptor<DocumentType> {
    let sortDescriptor = NSSortDescriptor(key: identifier, ascending: true)
    return SortDescriptor(sortDescriptor: sortDescriptor)
  }

  public func descending() -> SortDescriptor<DocumentType> {
    let sortDescriptor = NSSortDescriptor(key: identifier, ascending: false)
    return SortDescriptor(sortDescriptor: sortDescriptor)
  }
}
