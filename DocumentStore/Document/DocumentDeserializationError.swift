//
//  DocumentDeserializationError.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 07-11-16.
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
