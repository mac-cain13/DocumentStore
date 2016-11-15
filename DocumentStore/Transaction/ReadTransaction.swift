//
//  ReadTransaction.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 12-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

/// A transaction on a `DocumentStore` that only can perform reads, no writes are possible.
public class ReadTransaction: ReadableTransaction {
  private let transaction: ReadableTransaction

  init(transaction: ReadableTransaction) {
    self.transaction = transaction
  }

  func count<CollectionType: Collection>(_ collection: CollectionType) throws -> Int {
    return try transaction.count(collection)
  }

  func fetch<CollectionType: Collection>(_ collection: CollectionType) throws -> [CollectionType.DocumentType] {
    return try transaction.fetch(collection)
  }
}
