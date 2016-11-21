//
//  IndexValueType.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 04-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

/// Type that can be used as the value for an `Index`.
public protocol IndexValueType {
  /// Type of storage that should be used when storing this value.
  static var indexStorageType: IndexStorageType { get }
}

extension Bool: IndexValueType {
  /// Conforms `Bool` to `IndexValueType`
  public static var indexStorageType: IndexStorageType { return .bool }
}

extension Date: IndexValueType {
  /// Conforms `Date` to `IndexValueType`
  public static var indexStorageType: IndexStorageType { return .date }
}

extension Double: IndexValueType {
  /// Conforms `Double` to `IndexValueType`
  public static var indexStorageType: IndexStorageType { return .double }
}

extension Int: IndexValueType {
  /// Conforms `Int` to `IndexValueType`
  public static var indexStorageType: IndexStorageType { return .int }
}

extension String: IndexValueType {
  /// Conforms `String` to `IndexValueType`
  public static var indexStorageType: IndexStorageType { return .string }
}
