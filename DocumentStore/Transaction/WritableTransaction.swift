//
//  WritableTransaction.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 12-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

protocol WritableTransaction {
  @discardableResult
  func delete<CollectionType: Collection>(_ collection: CollectionType) throws -> Int

  func add<DocumentType: Document>(document: DocumentType) throws

  func saveChanges() throws
}
