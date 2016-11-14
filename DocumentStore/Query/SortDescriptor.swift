//
//  SortDescriptor.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 05-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

/// Description of how to sort a `Collection`.
public struct SortDescriptor<DocumentType: Document> {
  let sortDescriptor: NSSortDescriptor

  init(sortDescriptor: NSSortDescriptor) {
    self.sortDescriptor = sortDescriptor
  }
}

// MARK: Index sortdescriptors

public extension Index {
  /// `SortDescriptor` that orders the `Collection` on this `Index` ascending.
  ///
  /// Example: Ascending sorting is [1, 2, 3]
  ///
  /// - Returns: The `SortDescriptor` representing the ascending sorting
  public func ascending() -> SortDescriptor<DocumentType> {
    let sortDescriptor = NSSortDescriptor(key: identifier, ascending: true)
    return SortDescriptor(sortDescriptor: sortDescriptor)
  }

  /// `SortDescriptor` that orders the `Collection` on this `Index` descending.
  ///
  /// Example: Descending sorting is [3, 2, 1]
  ///
  /// - Returns: The `SortDescriptor` representing the descending sorting
  public func descending() -> SortDescriptor<DocumentType> {
    let sortDescriptor = NSSortDescriptor(key: identifier, ascending: false)
    return SortDescriptor(sortDescriptor: sortDescriptor)
  }
}
