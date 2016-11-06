//
//  Document.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 03-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

public struct DocumentDeserializationError: Error {
  public enum Resolution {
    /// Skips the item leaving it untouched in the store
    case Skip

    /// Removes the item from the store
    case Delete
  }

  public let resolution: Resolution
  public let underlyingError: Error

  public init(resolution: Resolution, underlyingError: Error) {
    self.resolution = resolution
    self.underlyingError = underlyingError
  }
}

// TODO: Wishlist; Documents with an identifier (generated value or specified by the protocol) 

public protocol Document {
  static var documentDescriptor: DocumentDescriptor<Self> { get }

  static func deserializeDocument(from data: Data) throws -> Self
  func serializeDocument() throws -> Data
}

public extension Document {
  public static func query(with transaction: Transaction) -> Query<Self> {
    return Query(transaction: transaction)
  }
}
