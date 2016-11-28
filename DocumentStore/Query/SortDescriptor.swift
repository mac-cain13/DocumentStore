//
//  SortDescriptor.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 05-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

public enum Order {
  case ascending
  case descending

  var isAscending: Bool {
    switch self {
    case .ascending:
      return true
    case .descending:
      return false
    }
  }
}

/// Descriptor that can be used to sort `Document`s matched by a `Query`.
public struct SortDescriptor<DocumentType: Document> {
  let foundationSortDescriptor: NSSortDescriptor

  public init<StorableType: Storable>(forStorable storable: StorableType, order: Order) where StorableType.DocumentType == DocumentType {
    self.foundationSortDescriptor = NSSortDescriptor(key: storable.storageInformation.propertyName.keyPath, ascending: order.isAscending)
  }
}

public extension Index {
  // MARK: Sorting

  /// `SortDescriptor` that orders on this `Index` ascending.
  ///
  /// Example: Ascending sorting is [1, 2, 3]
  ///
  /// - Returns: The `SortDescriptor` representing the ascending sorting
  public func ascending() -> SortDescriptor<DocumentType> {
    return SortDescriptor(forStorable: self, order: .ascending)
  }

  /// `SortDescriptor` that orders on this `Index` descending.
  ///
  /// Example: Descending sorting is [3, 2, 1]
  ///
  /// - Returns: The `SortDescriptor` representing the descending sorting
  public func descending() -> SortDescriptor<DocumentType> {
    return SortDescriptor(forStorable: self, order: .descending)
  }
}
