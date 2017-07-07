//
//  StorageInformation.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 24-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

enum PropertyName: Equatable, Validatable {
  case libraryDefined(String)
  case userDefined(String)

  var keyPath: String {
    switch self {
    case let .libraryDefined(keyPath):
      return keyPath
    case let .userDefined(name):
      return name
    }
  }

  func validate() -> [ValidationIssue] {
    guard case let .userDefined(name) = self else {
      return []
    }

    // Name may not be empty
    if name.isEmpty {
      return [ValidationIssue("Name may not be empty.")]
    }

    // Name may not start with `_`
    if name.characters.first == "_" {
      return [ValidationIssue("`\(name)` is an invalid name, names may not start with an `_`.")]
    }

    return []
  }

  static func == (lhs: PropertyName, rhs: PropertyName) -> Bool {
    switch (lhs, rhs) {
    case let (.libraryDefined(lhsKeyPath), .libraryDefined(rhsKeyPath)):
      return lhsKeyPath == rhsKeyPath
    case let (.userDefined(lhsName), .userDefined(rhsName)):
      return lhsName == rhsName
    default:
      return false
    }
  }
}
