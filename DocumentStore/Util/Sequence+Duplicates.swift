//
//  Sequence+Duplicates.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 06-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

extension Sequence where Iterator.Element: Hashable {
  func duplicates() -> Set<Iterator.Element> {
    return Set(filter { element in filter({ $0 == element }).count > 1 })
  }
}
