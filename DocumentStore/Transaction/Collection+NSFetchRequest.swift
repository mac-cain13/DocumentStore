//
//  Collection+NSFetchRequest.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 07-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation
import CoreData

extension Query {
  func fetchRequest<ResultType>() -> NSFetchRequest<ResultType> {
    let request = NSFetchRequest<ResultType>(entityName: DocumentType.documentDescriptor.identifier)
    request.predicate = predicate?.predicate
    request.fetchOffset = Int(exactly: skip) ?? Int.max

    if !sortDescriptors.isEmpty {
      request.sortDescriptors = sortDescriptors.map { $0.sortDescriptor }
    }

    if let limit = limit {
      // fetchLimit is typed as `Int`, but actually is and acts like a UInt32
      request.fetchLimit = UInt32(exactly: limit).map(Int.init) ?? Int(UInt32.max)
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
