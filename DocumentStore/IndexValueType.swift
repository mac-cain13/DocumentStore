//
//  IndexValueType.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 04-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation
import CoreData

public protocol IndexValueType {
  static var indexStorageType: IndexStorageType { get }
}

extension Bool: IndexValueType {
  public static var indexStorageType: IndexStorageType { return .bool }
}

extension Date: IndexValueType {
  public static var indexStorageType: IndexStorageType { return .date }
}

extension Double: IndexValueType {
  public static var indexStorageType: IndexStorageType { return .double }
}

extension Int: IndexValueType {
  public static var indexStorageType: IndexStorageType { return .int }
}

extension String: IndexValueType {
  public static var indexStorageType: IndexStorageType { return .string }
}

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
