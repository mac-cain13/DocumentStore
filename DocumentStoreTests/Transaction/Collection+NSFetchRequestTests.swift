//
//  Collection+NSFetchRequestTests.swift
//  DocumentStore
//
//  Created by Mathijs Kadijk on 13-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import XCTest
@testable import DocumentStore
import CoreData

class CollectionNSFetchRequestTests: XCTestCase {

  private let collection = TestCollection()

  func testFetchRequestEntityName() {
    let request: NSFetchRequest<NSManagedObject> = collection.fetchRequest()
    XCTAssertEqual(request.entityName, TestCollection.DocumentType.documentDescriptor.identifier)
  }

  func testFetchRequestPredicate() {
    let request: NSFetchRequest<NSManagedObject> = collection.fetchRequest()
    XCTAssertEqual(request.predicate, collection.predicate?.predicate)
  }

  func testFetchRequestFetchOffset() {
    let request: NSFetchRequest<NSManagedObject> = collection.fetchRequest()
    XCTAssertEqual(request.fetchOffset, Int(collection.skip))
  }

  func testFetchRequestFetchOffsetMaxUInt() {
    var collection = self.collection
    collection.skip = UInt.max
    let request: NSFetchRequest<NSManagedObject> = collection.fetchRequest()
    XCTAssertEqual(request.fetchOffset, Int.max)
  }

  func testFetchRequestFetchLimitNil() {
    let request: NSFetchRequest<NSManagedObject> = collection.fetchRequest()
    XCTAssertEqual(request.fetchLimit, 0)
  }

  func testFetchRequestFetchLimit() {
    let limit = 42
    var collection = self.collection
    collection.limit = UInt(limit)
    let request: NSFetchRequest<NSManagedObject> = collection.fetchRequest()
    XCTAssertEqual(request.fetchLimit, limit)
  }

  func testFetchRequestFetchLimitMaxUInt() {
    var collection = self.collection
    collection.skip = UInt.max
    let request: NSFetchRequest<NSManagedObject> = collection.fetchRequest()
    XCTAssertEqual(request.fetchOffset, Int.max)
  }

  func testFetchRequestSortDescriptorsWhenUnordered() {
    let request: NSFetchRequest<NSManagedObject> = collection.fetchRequest()
    XCTAssertNil(request.sortDescriptors)
  }

  func testFetchRequestSortDescriptors() {
    let sortDescriptor = TestDocument.isTest.ascending()
    let orderedCollection = collection.ordered { _ in sortDescriptor }
    let request: NSFetchRequest<NSManagedObject> = orderedCollection.fetchRequest()

    guard let sortDescriptors = request.sortDescriptors else {
      XCTFail("Sort descriptors empty.")
      return
    }

    XCTAssertEqual(sortDescriptors, [sortDescriptor].map { $0.sortDescriptor })
  }

  func testFetchRequestResultType() {
    let requestObject: NSFetchRequest<NSManagedObject> = collection.fetchRequest()
    XCTAssertEqual(requestObject.resultType, .managedObjectResultType)

    let requestId: NSFetchRequest<NSManagedObjectID> = collection.fetchRequest()
    XCTAssertEqual(requestId.resultType, .managedObjectIDResultType)

    let requestDict: NSFetchRequest<NSDictionary> = collection.fetchRequest()
    XCTAssertEqual(requestDict.resultType, .dictionaryResultType)

    let requestCount: NSFetchRequest<NSNumber> = collection.fetchRequest()
    XCTAssertEqual(requestCount.resultType, .countResultType)
  }
}

private struct TestCollection: DocumentStoreCollection {
  typealias DocumentType = TestDocument

  var predicate: Predicate<DocumentType>?
  var skip: UInt
  var limit: UInt?

  init() {
    self.predicate = Predicate<TestDocument>(predicate: NSPredicate(value: false))
    self.skip = 42
    self.limit = nil
  }
}

private struct TestDocument: Document {
  static let isTest = Index<TestDocument, Bool>(identifier: "") { _ in false }
  static let documentDescriptor = DocumentDescriptor<TestDocument>(identifier: "TestDocument", indices: [])

  func serializeDocument() throws -> Data {
    return Data()
  }

  static func deserializeDocument(from data: Data) throws -> TestDocument {
    return TestDocument()
  }
}
