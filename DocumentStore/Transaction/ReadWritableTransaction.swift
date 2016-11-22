//
//  ReadWritableTransaction.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 12-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

protocol ReadWritableTransaction: ReadableTransaction {
  @discardableResult
  func delete<DocumentType>(matching query: Query<DocumentType>) throws -> Int

  func add<DocumentType: Document>(document: DocumentType) throws

  func saveChanges() throws
}
