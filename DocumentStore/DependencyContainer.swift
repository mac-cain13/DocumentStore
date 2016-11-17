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
  var persistentContainerFactory: PersistentContainerFactory
  var transactionFactory: TransactionFactory

  init() {
    managedObjectModelService = ManagedObjectModelServiceImpl()
    persistentContainerFactory = NSPersistentContainerFactory()
    transactionFactory = CoreDataTransactionFactory()
  }

  func restoreDefaults() {
    let container = DependencyContainer()
    managedObjectModelService = container.managedObjectModelService
    persistentContainerFactory = container.persistentContainerFactory
    transactionFactory = container.transactionFactory
  }
}
