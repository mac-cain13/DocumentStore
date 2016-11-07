//
//  Collection+NSFetchRequest.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 07-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation
import CoreData

extension Collection {
  func fetchRequest<ResultType>() -> NSFetchRequest<ResultType> {
    let request = NSFetchRequest<ResultType>(entityName: DocumentType.documentDescriptor.identifier)
    request.predicate = predicate
    request.sortDescriptors = sortDescriptors
    request.fetchOffset = skip
    if let limit = limit {
      request.fetchLimit = limit
    }

    switch ResultType.self {
    case is NSManagedObject.Type:
      request.resultType = .managedObjectResultType
    case is NSManagedObjectID.Type:
      request.resultType = .managedObjectIDResultType
    case is NSDictionary.Type:
      request.resultType = .dictionaryResultType
    case is NSNumber.Type:
      request.resultType = .countResultType
    default:
      assertionFailure("This type of NSFetchRequestResult is not supported by DocumentStore.Transaction.")
    }

    return request
  }
}
