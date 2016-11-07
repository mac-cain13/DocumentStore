//
//  TransactionError.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 07-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

public enum TransactionError: Error {
  case ActionThrewError(Error)
  case SaveFailed(Error)
  case SerializationFailed(Error)
  case DocumentStoreError(DocumentStoreError)
}
