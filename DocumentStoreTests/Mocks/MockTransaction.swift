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
  var deleteQueryCalls = 0
  var deleteDocumentCalls = 0
  var saveCalls = 0
  var persistChangesCalls = 0

  var fetchLimitCallback: ((UInt?) -> Void)?

  func count<DocumentType>(matching query: Query<DocumentType>) throws -> Int {
    countCalls += 1
    return 42
  }

  func fetch<DocumentType>(matching query: Query<DocumentType>) throws -> [DocumentType] {
    fetchCalls += 1
    fetchLimitCallback?(query.limit)

    guard let data = "{}".data(using: .utf8) else { fatalError("Failed to create data") }
    return [
      try? DocumentType.decode(from: data),
      try? DocumentType.decode(from: data)
    ].compactMap { $0 }
  }

  @discardableResult
  func delete<DocumentType>(matching query: Query<DocumentType>) throws -> Int {
    deleteQueryCalls += 1
    return 1
  }

  func delete<DocumentType: Document>(document: DocumentType) throws -> Bool {
    deleteDocumentCalls += 1
    return true
  }

  func insert<DocumentType: Document>(document: DocumentType, mode: InsertMode) throws -> Bool {
    saveCalls += 1
    return true
  }

  func persistChanges() throws {
    persistChangesCalls += 1
  }
}
