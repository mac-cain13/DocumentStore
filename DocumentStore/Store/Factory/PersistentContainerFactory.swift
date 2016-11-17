//
//  PersistentContainerFactory.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 17-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation
import CoreData

protocol PersistentContainerFactory {
  func createPersistentContainer(name: String, managedObjectModel: NSManagedObjectModel) -> NSPersistentContainer
}
