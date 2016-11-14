//
//  TransactionError.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 07-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

public enum TransactionError: Error {
  case actionThrewError(Error)
  case saveFailed(Error)
  case serializationFailed(Error)
  case documentStoreError(DocumentStoreError)
}
