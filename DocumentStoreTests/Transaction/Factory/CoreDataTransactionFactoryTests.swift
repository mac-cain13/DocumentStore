//
//  CoreDataTransactionFactoryTests.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 18-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import XCTest
@testable import DocumentStore
import CoreData

class CoreDataTransactionFactoryTests: XCTestCase {

  func testCreateTransaction() {
    let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    let descriptors = ValidatedDocumentDescriptors(documentDescriptors: [])
    let logger = MockLogger()

    let factory = CoreDataTransactionFactory()
    let transaction = factory.createTransaction(context: context, documentDescriptors: descriptors, logTo: logger)

    XCTAssertTrue(transaction is CoreDataTransaction)
  }
}
