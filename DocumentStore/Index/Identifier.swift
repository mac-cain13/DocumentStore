//
//  Identifier.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 28-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

// TODO
public struct Identifier<DocumentType: Document, ValueType: StorableValue>: Storable {
  public let storageInformation: StorageInformation<DocumentType, ValueType>
  public let resolver: (DocumentType) -> ValueType?

  public init(resolver: @escaping (DocumentType) -> ValueType) {
    self.storageInformation = StorageInformation(propertyName: .libraryDefined(DocumentIdentifierAttributeName), isOptional: false)
    self.resolver = resolver
  }
}
