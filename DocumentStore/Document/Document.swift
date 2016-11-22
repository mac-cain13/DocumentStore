//
//  Document.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 03-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

/// A type that provides an interface to transfer types to a document store and back.
public protocol Document {
  /// Description that indentifies the document and determens how it should be indexed.
  static var documentDescriptor: DocumentDescriptor<Self> { get }

  /// Deserializes a stored document back into its original state.
  ///
  /// - Note: You should be able to deserialize any `Data` that is outputted by the
  ///         `serializeDocument` method. Not being able to do so will result in data loss. Throw an
  ///         `DocumentDeserializationError` with the appropiate `Resolution` if you do fail to
  ///         deserialize the `Data`. Throwing any other `Error` will behave the same as an
  ///         `DocumentDeserializationError` with the `.abortOperation` resolution.
  ///
  /// - Parameter data: The data exactly as it was serialized
  /// - Returns: The deserialized document from the data
  /// - Throws: Either an `DocumentDeserializationError` or any other `Error`
  static func deserializeDocument(from data: Data) throws -> Self

  /// Serializes the document to `Data` for storage.
  ///
  /// - Note: You should make sure every document is serializable and only throw an `Error` in extreme
  ///         edge cases where the serializer in use fails on you. Because throwing will make the
  ///         whole operation in progress fail.
  ///
  /// - Returns: Data representing the document that can be handled by `deserializeDocument`
  /// - Throws: Any `Error` to indicate that deserialization failed
  func serializeDocument() throws -> Data
}
