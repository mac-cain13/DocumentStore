//
//  Validatable.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 06-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

/// Representation of an issue found during validation.
typealias ValidationIssue = String

/// A type that provides validation of elements that cannot be expressed in the typesystem.
protocol Validatable {
  /// Perform validation of this instance.
  ///
  /// - Returns: List of all validation issues
  func validate() -> [ValidationIssue]
}

extension Sequence where Iterator.Element: Validatable {
  /// Validate all items in this sequence.
  ///
  /// - Returns: Flattened list of all validation issues
  func validate() -> [ValidationIssue] {
    return flatMap { $0.validate() }
  }
}
