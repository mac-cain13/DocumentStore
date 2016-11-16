//
//  DocumentStoreError.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 07-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

/// Error in direct relation with the `DocumentStore`
public struct DocumentStoreError: Error, CustomStringConvertible {
  /// Kind of error the `DocumentStore` encountered
  ///
  /// - storeIdentifierInvalid: Given `DocumentStore` identifier is invalid
  /// - documentDescriptionInvalid: One or more `DocumentDescriptor`s are invalid
  /// - documentDescriptionNotRegistered: Tried to perform an operation with a `Document` which `DocumentDescriptor` was not registered with this store
  /// - operationFailed: The operation failed due errors with the system or issues in the library
  /// - documentDataCorruption: Couldn't read the serialized data of a `Document` from disk
  public enum ErrorKind: Int {
    /// Given `DocumentStore` identifier is invalid
    case storeIdentifierInvalid = 1

    /// One or more `DocumentDescriptor`s are invalid
    case documentDescriptionInvalid

    /// Tried to perform an operation with a `Document` which `DocumentDescriptor` was not registered with this store
    case documentDescriptionNotRegistered

    /// The operation failed due errors with the system or issues in the library
    case operationFailed

    /// Couldn't read the serialized data of a `Document` from disk
    case documentDataCorruption
  }

  /// The kind of error encountered
  public let kind: ErrorKind

  /// Message describing the error
  public let message: String

  /// The underlying more technical error that triggered this error, if any.
  public let underlyingError: Error?

  /// A programmer readable version of the error, including any underlying error if present.
  public var description: String {
    let underlyingErrorDescription = underlyingError.map { " - \($0)" } ?? ""
    return "DocumentStoreError #\(kind.rawValue): \(message)\(underlyingErrorDescription)"
  }
}
