//
//  Validatable.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 06-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

typealias ValidationIssue = String

protocol Validatable {
  func validate() -> [ValidationIssue]
}

extension Sequence where Iterator.Element: Validatable {
  func validate() -> [ValidationIssue] {
    return flatMap { $0.validate() }
  }
}
