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
  ///
  /// - Note: `deleteDocument` will only persist the deletion if you commit the transaction with
  ///         `CommitAction.saveChanges`.
  ///
  /// - Warning: `abortOperation` will make every `Collection` containing this particular document
  ///            to fail with an error. Use `skipDocument` to not remove the data, but continue 
  ///            gracefully.
  ///
  /// - skipDocument: Skips the `Document` leaving it untouched in the store
  /// - deleteDocument: Removes the `Document` from the store
  /// - abortOperation: Abort the current operation
  public enum Resolution {
    /// Skips the `Document` leaving it untouched in the store.
    case skipDocument

    /// Removes the `Document` from the store.
    ///
    /// - Note: `deleteDocument` will only persist the deletion if you commit the transaction with
    ///         `CommitAction.saveChanges`.
    case deleteDocument

    /// Abort the current operation.
    ///
    /// - Warning: `abortOperation` will make every `Collection` containing this particular document
    ///            to fail with an error. Use `skipDocument` to not remove the data, but continue
    ///            gracefully.
    case abortOperation
  }

  let resolution: Resolution
  let underlyingError: Error

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
