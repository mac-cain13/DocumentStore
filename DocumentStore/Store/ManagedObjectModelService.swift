//
//  ManagedObjectModelService.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 16-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation
import CoreData

protocol ManagedObjectModelService {
  func validate(_ documentDescriptors: [AnyDocumentDescriptor], logTo logger: Logger) throws -> ValidatedDocumentDescriptors
  func generateModel(from validatedDocumentDescriptors: ValidatedDocumentDescriptors, logTo logger: Logger) -> NSManagedObjectModel
}

final class ManagedObjectModelServiceImpl: ManagedObjectModelService {
  func validate(_ documentDescriptors: [AnyDocumentDescriptor], logTo logger: Logger) throws -> ValidatedDocumentDescriptors {
    let validationIssues = documentDescriptors.validate() + documentDescriptors
      .map { $0.name }
      .duplicates()
      .map { "Multiple DocumentDescriptors have `\($0)` as name, every document descriptor must have an unique name." }

    guard validationIssues.isEmpty else {
      let errorMessage = "One or more document descriptors are invalid:\n - " + validationIssues.joined(separator: "\n - ")
      logger.log(level: .warn, message: errorMessage)
      throw DocumentStoreError(kind: .documentDescriptionInvalid, message: errorMessage, underlyingError: nil)
    }

    return ValidatedDocumentDescriptors(documentDescriptors: documentDescriptors)
  }

  func generateModel(from validatedDocumentDescriptors: ValidatedDocumentDescriptors, logTo logger: Logger) -> NSManagedObjectModel {
    logger.log(level: .trace, message: "Creating shared attribute `_documentData`...")
    let documentDataAttribute = NSAttributeDescription()
    documentDataAttribute.name = DocumentDataAttributeName
    documentDataAttribute.attributeType = .binaryDataAttributeType
    documentDataAttribute.isIndexed = false
    documentDataAttribute.isOptional = false
    documentDataAttribute.allowsExternalBinaryDataStorage = true

    let model = NSManagedObjectModel()
    model.entities = validatedDocumentDescriptors.documentDescriptors
      .map { documentDescriptor in
        logger.log(level: .trace, message: "Creating entity `\(documentDescriptor.name)`...")

        let indexAttributes = documentDescriptor.indices
          .map { index -> NSAttributeDescription in
            logger.log(level: .trace, message: "  Creating attribute `\(index.propertyName.keyPath)` of type \(index.storageType.attributeType)...")

            let attribute = NSAttributeDescription()
            attribute.name = index.propertyName.keyPath
            attribute.attributeType = index.storageType.attributeType
            attribute.isIndexed = true
            attribute.isOptional = false
            attribute.allowsExternalBinaryDataStorage = false
            return attribute
        }

        let entity = NSEntityDescription()
        entity.name = documentDescriptor.name
        entity.properties = [documentDataAttribute] + indexAttributes
        return entity
    }

    return model
  }
}
