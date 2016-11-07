//
//  DocumentDescriptor.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 04-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation
import CoreData

public struct DocumentDescriptor<DocumentType: Document> {
  let identifier: String
  let indices: [AnyIndex<DocumentType>]

  public init(identifier: String, indices: [AnyIndex<DocumentType>]) {
    self.identifier = identifier
    self.indices = indices
  }

  public func eraseType() -> AnyDocumentDescriptor {
    return AnyDocumentDescriptor(descriptor: self)
  }
}

public struct AnyDocumentDescriptor: Validatable, Equatable {
  let identifier: String
  let indices: [UntypedAnyIndex]

  public init<DocumentType>(descriptor: DocumentDescriptor<DocumentType>) {
    self.identifier = descriptor.identifier
    self.indices = descriptor.indices.map(UntypedAnyIndex.init)
  }

  func validate() -> [ValidationIssue] {
    var issues: [ValidationIssue] = []

    // Identifiers may not start with `_`
    if identifier.characters.first == "_" {
      issues.append("`\(identifier)` is an invalid identifier DocumentDescriptor, identifiers may not start with an `_`.")
    }

    // Indices also should be valid
    issues += indices.flatMap { $0.validate() }

    // Two indices may not have the same identifier
    issues += indices
      .map { $0.identifier }
      .duplicates()
      .map {
        "DocumentDescriptor `\(identifier)` has multiple indices with `\($0)` as identifier, every index identifier must be unique."
      }

    return issues
  }

  public static func == (lhs: AnyDocumentDescriptor, rhs: AnyDocumentDescriptor) -> Bool {
    return lhs.identifier == rhs.identifier && lhs.indices == rhs.indices
  }
}

// MARK: Operations on a list of document descriptors

func validate(_ documentDescriptors: [AnyDocumentDescriptor], logTo logger: Logger) throws {
  let validationIssues = documentDescriptors.validate() + documentDescriptors
    .map { $0.identifier }
    .duplicates()
    .map { "Multiple DocumentDescriptors have `\($0)` as identifier, every document descriptor must have an unique identifier." }

  guard validationIssues.isEmpty else {
    let errorMessage = "One or more document descriptors are invalid:\n - " + validationIssues.joined(separator: "\n - ")
    logger.log(level: .warn, message: errorMessage)
    throw DocumentStoreError(kind: .documentDescriptionInvalid, message: errorMessage, underlyingError: nil)
  }
}

func managedObjectModel(from documentDescriptors: [AnyDocumentDescriptor], logTo logger: Logger) -> NSManagedObjectModel {
  logger.log(level: .trace, message: "Creating shared attribute `_DocumentData`...")
  let documentDataAttribute = NSAttributeDescription()
  documentDataAttribute.name = DocumentDataAttributeName
  documentDataAttribute.attributeType = .binaryDataAttributeType
  documentDataAttribute.isIndexed = false
  documentDataAttribute.isOptional = false
  documentDataAttribute.allowsExternalBinaryDataStorage = true

  let model = NSManagedObjectModel()
  model.entities = documentDescriptors
    .map { documentDescriptor in
      logger.log(level: .trace, message: "Creating entity `\(documentDescriptor.identifier)`...")

      let indexAttributes = documentDescriptor.indices
        .map { index -> NSAttributeDescription in
          logger.log(level: .trace, message: "  Creating attribute `\(index.identifier)` of type \(index.storageType.attributeType)...")

          let attribute = NSAttributeDescription()
          attribute.name = index.identifier
          attribute.attributeType = index.storageType.attributeType
          attribute.isIndexed = true
          attribute.isOptional = false
          attribute.allowsExternalBinaryDataStorage = false
          return attribute
      }

      let entity = NSEntityDescription()
      entity.name = documentDescriptor.identifier
      entity.properties = [documentDataAttribute] + indexAttributes
      return entity
  }
  
  return model
}
