//
//  DocumentStore+BrightFutures.swift
//  PromiseWrappers
//
//  Created by Mathijs Kadijk on 07/04/2019.
//  Copyright © 2019 Mathijs Kadijk. All rights reserved.
//

import DocumentStore
import BrightFutures

private let promiseQueue = DispatchQueue(label: "nl.mathijskadijk.DocumentStore.brightFutures", qos: .unspecified, attributes: .concurrent)

public extension DocumentStore {
  /// Perform a read transaction on the store and get the result back in a handler.
  ///
  /// - Warning: Do not use the `ReadTransaction` outside of the actions block, this will result in
  ///            undefined behaviour.
  ///
  /// - Note: Actions block will be executed on an arbitrary background thread managed by the store.
  ///
  /// - Parameters:
  ///   - actions: Actions to perform in this transaction, returned result is passed to the handler
  /// - Returns: `Future` with the result of the transaction
  func read<T>(actions: @escaping (ReadTransaction) throws -> T) -> Future<T, TransactionError> {
    return Future { complete in
      read(queue: promiseQueue,
           handler: { result in
             switch result {
             case let .success(value):
               complete(.success(value))
             case let .failure(error):
               complete(.failure(error))
             }
           },
           actions: actions)
    }
  }

  /// Perform a write transaction on the store.
  ///
  /// - Warning: Do not use the `ReadWriteTransaction` outside of the actions block, this will
  ///            result in undefined behaviour.
  ///
  /// - Note: Actions block will be executed on an arbitrary background thread managed by the store.
  ///
  /// - Parameters:
  ///   - actions: Actions to perform in this transaction, returned commit action will be executed
  /// - Returns: `Future` with the result of the transaction
  func write(actions: @escaping (ReadWriteTransaction) throws -> CommitAction) -> Future<Void, TransactionError> {
    return Future { complete in
      write(queue: promiseQueue,
            handler: { error in
              if let error = error {
                complete(.failure(error))
              } else {
                complete(.success(()))
              }
            },
            actions: actions)
    }
  }

  /// Perform a read/write transaction on the store and get the result back in a handler.
  ///
  /// - Warning: Do not use the `ReadWriteTransaction` outside of the actions block, this will
  ///            result in undefined behaviour.
  ///
  /// - Note: Actions block will be executed on an arbitrary background thread managed by the store.
  ///
  /// - Parameters:
  ///   - actions: Actions to perform in this transaction, returned result is passed to the handler, commit action will be executed
  /// - Returns: `Future` with the result of the transaction
  func readWrite<T>(actions: @escaping (ReadWriteTransaction) throws -> (CommitAction, T)) -> Future<T, TransactionError> {
    return Future { complete in
      readWrite(queue: promiseQueue,
                handler: { result in
                  switch result {
                  case let .success(value):
                    complete(.success(value))
                  case let .failure(error):
                    complete(.failure(error))
                  }
                },
                actions: actions)
    }
  }
}

