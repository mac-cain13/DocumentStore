//
//  ReadableTransaction.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 12-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

protocol ReadableTransaction {
  func count<CollectionType: Collection>(_ collection: CollectionType) throws -> Int

  func fetch<CollectionType: Collection>(_ collection: CollectionType) throws -> [CollectionType.DocumentType]
}
