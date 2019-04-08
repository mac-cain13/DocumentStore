//
//  DocumentStore+Promissum.swift
//  PromiseWrappers
//
//  Created by Mathijs Kadijk on 07/04/2019.
//  Copyright © 2019 Mathijs Kadijk. All rights reserved.
//

import DocumentStore
import Promissum

private let promiseQueue = DispatchQueue(label: "nl.mathijskadijk.DocumentStore.promissum", qos: .unspecified, attributes: .concurrent)

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
  /// - Returns: `Promise` with the result of the transaction
  func read<T>(actions: @escaping (ReadTransaction) throws -> T) -> Promise<T, TransactionError> {
    let promiseSource = PromiseSource<T, TransactionError>()
    read(queue: promiseQueue,
         handler: { result in
           switch result {
           case let .success(value):
             promiseSource.resolve(value)
           case let .failure(error):
             promiseSource.reject(error)
           }
         },
         actions: actions)
    return promiseSource.promise
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
  /// - Returns: `Promise` with the result of the transaction
  func write(actions: @escaping (ReadWriteTransaction) throws -> CommitAction) -> Promise<Void, TransactionError> {
    let promiseSource = PromiseSource<Void, TransactionError>()
    write(queue: promiseQueue,
          handler: { error in
            if let error = error {
              promiseSource.reject(error)
            } else {
              promiseSource.resolve(())
            }
         },
         actions: actions)
    return promiseSource.promise
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
  /// - Returns: `Promise` with the result of the transaction
  func readWrite<T>(actions: @escaping (ReadWriteTransaction) throws -> (CommitAction, T)) -> Promise<T, TransactionError> {
    let promiseSource = PromiseSource<T, TransactionError>()
    readWrite(queue: promiseQueue,
              handler: { result in
                switch result {
                case let .success(value):
                  promiseSource.resolve(value)
                case let .failure(error):
                  promiseSource.reject(error)
                }
              },
              actions: actions)
    return promiseSource.promise
  }
}
