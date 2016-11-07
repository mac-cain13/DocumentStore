//
//  ReadWriteTransaction.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 07-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import Foundation
import CoreData

public final class ReadWriteTransaction: ReadTransaction {
  private let context: NSManagedObjectContext
  private let logger: Logger

  override init(context: NSManagedObjectContext, documentDescriptors: [AnyDocumentDescriptor], logTo logger: Logger) {
    self.context = context
    self.logger = logger
    super.init(context: context, documentDescriptors: documentDescriptors, logTo: logger)
  }

  @discardableResult
  public func delete<DocumentType>(matching query: Query<DocumentType>) throws -> Int {
    try validateUseOfDocumentType(DocumentType.self)

    let request: NSFetchRequest<NSManagedObject> = query.fetchRequest()
    request.includesPropertyValues = false

    do {
      let fetchResult = try context.fetch(request)
      fetchResult.forEach(context.delete)
      return fetchResult.count
    } catch let underlyingError {
      let error = DocumentStoreError(
        kind: .fetchRequestFailed,
        message: "Failed to fetch '\(DocumentType.documentDescriptor.identifier)' documents. This is an error in the DocumentStore library, please report this issue.",
        underlyingError: underlyingError
      )
      logger.log(level: .error, message: "Error while performing fetch.", error: error)
      throw TransactionError.DocumentStoreError(error)
    }
  }

  public func add<DocumentType: Document>(document: DocumentType) throws {
    try validateUseOfDocumentType(DocumentType.self)

    let entity = NSEntityDescription.insertNewObject(forEntityName: DocumentType.documentDescriptor.identifier, into: context)

    do {
      let documentData = try document.serializeDocument()
      entity.setValue(documentData, forKey: DocumentDataAttributeName)
    } catch let error {
      throw TransactionError.SerializationFailed(error)
    }

    DocumentType.documentDescriptor.indices.forEach {
      entity.setValue($0.resolver(document), forKey: $0.identifier)
    }
  }

  func saveChanges() throws {
    if context.hasChanges {
      try context.save()
    }
  }
}
