//
//  ReadWritableTransaction.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 12-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

public enum SaveMode {
  case addOrReplace
  case addOnly
  case replaceOnly
}

protocol ReadWritableTransaction: ReadableTransaction {
  @discardableResult
  func save<DocumentType: Document>(document: DocumentType, saveMode: SaveMode) throws -> Bool

  @discardableResult
  func delete<DocumentType>(matching query: Query<DocumentType>) throws -> Int

  @discardableResult
  func delete<DocumentType: Document>(document: DocumentType) throws -> Bool

  func persistChanges() throws
}
