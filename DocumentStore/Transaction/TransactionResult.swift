//
//  TransactionResult.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 07-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

public enum TransactionResult<T> {
  case success(T)
  case failure(TransactionError)
}
