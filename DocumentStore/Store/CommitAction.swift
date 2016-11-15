//
//  CommitAction.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 07-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation

/// Action to take when the `ReadWriteTransaction` is completed.
///
/// - saveChanges: Save the changes made
/// - discardChanges: Discard any changes that have been made
public enum CommitAction {
  /// Save the changes made
  case saveChanges

  /// Discard any changes that have been made
  case discardChanges
}
