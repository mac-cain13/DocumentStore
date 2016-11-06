//
//  DocumentStoreError.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 06-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

public struct DocumentStoreError: Error, CustomStringConvertible {
  public enum ErrorKind: Int {
    case fetchRequestFailed = 1
    case documentDataAttributeCorruption
  }

  public let kind: ErrorKind
  public let message: String
  public let underlyingError: Error?

  public var description: String {
    let underlyingErrorDescription = underlyingError.map { " - \($0)" } ?? ""
    return "DocumentStoreError #\(kind.rawValue): \(message)\(underlyingErrorDescription)"
  }
}
