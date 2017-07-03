//
//  IndexableValue.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 04-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

/// Types implementing this protocol can be stored for use in for example `Index`es or `Identifiers`.
public protocol IndexableValue {
  /// Type of storage that should be used when storing this value.
  static var storageType: StorageType { get }
}

extension Bool: IndexableValue {
  /// Conforms `Bool` to `StorableValue`
  public static var storageType: StorageType { return .bool }
}

extension Date: IndexableValue {
  /// Conforms `Date` to `StorableValue`
  public static var storageType: StorageType { return .date }
}

extension Double: IndexableValue {
  /// Conforms `Double` to `StorableValue`
  public static var storageType: StorageType { return .double }
}

extension Int: IndexableValue {
  /// Conforms `Int` to `StorableValue`
  public static var storageType: StorageType { return .int }
}

extension String: IndexableValue {
  /// Conforms `String` to `StorableValue`
  public static var storageType: StorageType { return .string }
}
