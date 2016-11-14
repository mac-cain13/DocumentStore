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
