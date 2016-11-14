//
//  IndexStorageType.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 07-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation
import CoreData

/// Type that describes the possible storage formats.
public enum IndexStorageType {
  /// Boolean storage
  case bool

  /// Date storage
  case date

  /// Double storage
  case double

  /// Int64 storage
  case int

  /// String storage
  case string

  /// The appropiate `NSAttributeType` for this `IndexStorageType`
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
