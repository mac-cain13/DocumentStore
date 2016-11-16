//
//  DependencyContainer.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 16-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

final class DependencyContainer {
  var managedObjectModelService: ManagedObjectModelService
  var transactionFactory: TransactionFactory

  init() {
    managedObjectModelService = ManagedObjectModelServiceImpl()
    transactionFactory = CoreDataTransactionFactory()
  }

  func restoreDefaults() {
    let container = DependencyContainer()
    managedObjectModelService = container.managedObjectModelService
    transactionFactory = container.transactionFactory
  }
}
