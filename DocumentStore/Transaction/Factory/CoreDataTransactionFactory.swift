//
//  CoreDataTransactionFactory.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 16-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation
import CoreData

class CoreDataTransactionFactory: TransactionFactory {
  func createTransaction(context: NSManagedObjectContext, documentDescriptors: ValidatedDocumentDescriptors, logTo logger: Logger) -> ReadWritableTransaction {
    return CoreDataTransaction(context: context, documentDescriptors: documentDescriptors, logTo: logger)
  }
}
