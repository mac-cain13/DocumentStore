//
//  Query+NSFetchRequest.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 07-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation
import CoreData

extension Query {
  func fetchRequest<ResultType>() -> NSFetchRequest<ResultType> {
    let request = NSFetchRequest<ResultType>(entityName: DocumentType.documentDescriptor.name)
    request.predicate = predicate?.foundationPredicate
    request.fetchOffset = Int(exactly: skip) ?? Int.max

    if !sortDescriptors.isEmpty {
      request.sortDescriptors = sortDescriptors.map { $0.foundationSortDescriptor }
    }

    if let limit = limit {
      // fetchLimit is typed as `Int`, but actually is and acts like a UInt32
      let limitAsUint32 = UInt32(exactly: limit) ?? UInt32.max
      let limitAsInt = Int(exactly: limitAsUint32) ?? Int.max
      request.fetchLimit = limitAsInt
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
