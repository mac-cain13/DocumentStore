//
//  TransactionError.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 07-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

/// Error thrown if a operation on a transaction fails.
///
/// - actionThrewError: The given block with actions threw an error and therefore the operation is aborted
/// - serializationFailed: The (de)serialization code threw an error
/// - documentStoreError: The `DocumentStore` threw an error that made this transaction fail
public enum TransactionError: Error {
  /// The given block with actions threw an error and therefore the operation is aborted.
  case actionThrewError(Error)

  /// The (de)serialization code threw an error.
  case serializationFailed(Error)

  /// The `DocumentStore` threw an error that made this transaction fail.
  case documentStoreError(DocumentStoreError)
}
