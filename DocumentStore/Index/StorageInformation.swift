//
//  StorageInformation.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 07-07-17.
//  Copyright © 2017 Mathijs Kadijk. All rights reserved.
//

import Foundation

struct StorageInformation: Equatable, Validatable {
  let documentName: String
  let propertyName: PropertyName
  let storageType: StorageType
  let isOptional: Bool
  let sourceKeyPath: AnyKeyPath?

  func validate() -> [ValidationIssue] {
    return propertyName.validate()
  }

  static func == (lhs: StorageInformation, rhs: StorageInformation) -> Bool {
    return lhs.documentName == rhs.documentName &&
      lhs.propertyName == rhs.propertyName &&
      lhs.storageType == rhs.storageType &&
      lhs.isOptional == rhs.isOptional &&
      lhs.sourceKeyPath == rhs.sourceKeyPath
  }
}
