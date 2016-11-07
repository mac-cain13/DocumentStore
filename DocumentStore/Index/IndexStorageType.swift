//
//  IndexStorageType.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 07-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation
import CoreData

public enum IndexStorageType {
  case bool
  case date
  case double
  case int
  case string

  var attributeType: NSAttributeType {
    switch self {
    case .bool:
      return .booleanAttributeType
    case .date:
      return .dateAttributeType
    case .double:
      return .doubleAttributeType
    case .int:
      return .integer64AttributeType
    case .string:
      return .stringAttributeType
    }
  }
}
