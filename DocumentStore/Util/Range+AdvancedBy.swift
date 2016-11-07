//
//  Range+AdvancedBy.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 06-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

extension Range where Bound: Integer {
  func advanced(by amount: Bound.Stride) -> Range<Bound> {
    return lowerBound.advanced(by: amount)..<upperBound.advanced(by: amount)
  }
}
