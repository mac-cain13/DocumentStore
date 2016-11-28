//
//  StorableValue.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 04-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

/// Types implementing this protocol can be stored for use in for example `Index`es or `Identifiers`.
public protocol StorableValue {
  /// Type of storage that should be used when storing this value.
  static var storageType: StorageType { get }
}

extension Bool: StorableValue {
  /// Conforms `Bool` to `StorableValue`
  public static var storageType: StorageType { return .bool }
}

extension Date: StorableValue {
  /// Conforms `Date` to `StorableValue`
  public static var storageType: StorageType { return .date }
}

extension Double: StorableValue {
  /// Conforms `Double` to `StorableValue`
  public static var storageType: StorageType { return .double }
}

extension Int: StorableValue {
  /// Conforms `Int` to `StorableValue`
  public static var storageType: StorageType { return .int }
}

extension String: StorableValue {
  /// Conforms `String` to `StorableValue`
  public static var storageType: StorageType { return .string }
}
