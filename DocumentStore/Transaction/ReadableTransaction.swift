//
//  ReadableTransaction.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 12-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

protocol ReadableTransaction {
  func count<DocumentType>(matching query: Query<DocumentType>) throws -> Int

  func fetch<DocumentType>(matching query: Query<DocumentType>) throws -> [DocumentType]
}
