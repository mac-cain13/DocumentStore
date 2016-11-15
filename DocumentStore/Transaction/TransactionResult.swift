//
//  TransactionResult.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 07-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

/// Result of a transaction, either successful with a value or failed with an error.
///
/// - success: Success indicator with the result value
/// - failure: Failure indicator with the error that appeared
public enum TransactionResult<T> {
  /// Success indicator with the result value.
  case success(T)

  /// Failure indicator with the error that appeared.
  case failure(TransactionError)
}
