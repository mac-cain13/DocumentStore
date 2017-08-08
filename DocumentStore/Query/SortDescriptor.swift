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

  /// `SortDescriptor` that orders on this `PartialIndex`.
  ///
  /// - Parameters:
  ///   - index: `PartialIndex` to sort on
  ///   - order: `Order` used to sort the `PartialIndex`
  /// - Returns: The `SortDescriptor` representing the ascending sorting
  public init(index: PartialIndex<DocumentType>, order: Order) {
    self.foundationSortDescriptor = NSSortDescriptor(key: index.storageInformation.propertyName.keyPath, ascending: order.isAscending)
  }

  /// `SortDescriptor` that looks up the `PartialIndex` associated with the given `PartialKeyPath` and orders on it.
  ///
  /// - Parameters:
  ///   - keyPath: `PartialKeyPath` to sort on
  ///   - order: `Order` used to sort the found `PartialIndex`
  /// - Returns: The `SortDescriptor` representing the ascending sorting
  public init(keyPath: PartialKeyPath<DocumentType>, order: Order) {
    guard let index = DocumentType.documentDescriptor.findIndex(basedOn: keyPath) else {
      fatalError("Using an unindexed KeyPath as a sort descriptor is not supported.")
    }

    self.foundationSortDescriptor = NSSortDescriptor(key: index.storageInformation.propertyName.keyPath, ascending: order.isAscending)
  }
}
