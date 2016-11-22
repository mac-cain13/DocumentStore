//
//  MockTransaction.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 22-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation
@testable import DocumentStore

class MockTransaction: ReadWritableTransaction {
  var countCalls = 0
  var fetchCalls = 0
  var deleteCalls = 0
  var addCalls = 0
  var saveCalls = 0

  var fetchLimitCallback: ((UInt?) -> Void)?

  func count<DocumentType>(matching query: Query<DocumentType>) throws -> Int {
    countCalls += 1
    return 42
  }

  func fetch<DocumentType>(matching query: Query<DocumentType>) throws -> [DocumentType] {
    fetchCalls += 1
    fetchLimitCallback?(query.limit)

    return [
      try? DocumentType.deserializeDocument(from: Data()),
      try? DocumentType.deserializeDocument(from: Data())
      ].flatMap { $0 }
  }

  @discardableResult
  func delete<DocumentType>(matching query: Query<DocumentType>) throws -> Int {
    deleteCalls += 1
    return 1
  }

  func add<DocumentType: Document>(document: DocumentType) throws {
    addCalls += 1
  }

  func saveChanges() throws {
    saveCalls += 1
  }
}
