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

  // TODO
  public func count<DocumentType>(matching query: Query<DocumentType>) throws -> Int {
    return try transaction.count(matching: query)
  }

  // TODO
  public func fetch<DocumentType>(matching query: Query<DocumentType>) throws -> [DocumentType] {
    return try transaction.fetch(matching: query)
  }
}
