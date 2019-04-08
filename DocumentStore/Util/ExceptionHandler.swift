//
//  ExceptionHandler.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 19-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation
import ObjCExceptionHandler

struct ConverExceptionHasNoResultError: Error {}

struct ExceptionError: Error {
  let exception: NSException
}

func convertExceptionToError<T>(block: () throws -> T) throws -> T {
  var result = Result<T, Error>.failure(ConverExceptionHasNoResultError())

  let exception = Exception.raised {
    do {
      result = .success(try block())
    } catch {
      result = .failure(error)
    }
  }

  if let exception = exception {
    throw ExceptionError(exception: exception)
  }

  switch result {
  case let .success(value):
    return value
  case let .failure(error):
    throw error
  }
}
