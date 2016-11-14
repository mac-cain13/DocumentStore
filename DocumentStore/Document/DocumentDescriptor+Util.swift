//
//  DocumentDescriptor+Util.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 07-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation
import CoreData

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
