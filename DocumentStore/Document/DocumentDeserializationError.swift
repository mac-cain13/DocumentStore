//
//  DocumentDeserializationError.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 07-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

/// Indicates a failure while deserializing a `Document` with the prefered `Resolution`.
public struct DocumentDeserializationError: Error {
  /// The prefered resolution for the `DocumentDeserializationError`.
  public enum Resolution {
    /// Skips the `Document` leaving it untouched in the store
    case skipDocument

    /// Removes the `Document` from the store
    case deleteDocument

    /// Abort the current operation
    case abortOperation
  }

  /// The prefered resolution to take
  public let resolution: Resolution

  /// The error that caused the deserialization failure
  public let underlyingError: Error

  /// Create the error.
  ///
  /// - Parameters:
  ///   - resolution: The prefered resolution to take
  ///   - underlyingError: The error that caused the deserialization failure
  public init(resolution: Resolution, underlyingError: Error) {
    self.resolution = resolution
    self.underlyingError = underlyingError
  }
}
