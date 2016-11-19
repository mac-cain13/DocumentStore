//
//  NSPersistentContainerFactoryTests.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 18-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import XCTest
@testable import DocumentStore
import CoreData

class NSPersistentContainerFactoryTests: XCTestCase {

  func testCreatePersistentContainer() {
    let name = "TestContainer"
    let model = NSManagedObjectModel()

    let factory = NSPersistentContainerFactory()
    let container = factory.createPersistentContainer(name: name, managedObjectModel: model)

    XCTAssertEqual(container.name, name)
    XCTAssertEqual(container.managedObjectModel, model)
  }
}
