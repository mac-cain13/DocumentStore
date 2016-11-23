//
//  DocumentStoreTests.swift
//  DocumentStoreTests
//
//  Created by Mathijs Kadijk on 02-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

import XCTest
import DocumentStore

////////

let documentStore = try? DocumentStore(
  identifier: "TestDocumentStore",
  documentDescriptors: [
    Developer.documentDescriptor.eraseType(),
    Shipment.documentDescriptor.eraseType()
  ]
)

struct Developer {
  let name: String
  let age: Int
}

extension Developer: Document {
  static let name: Index<Developer, String> = { Index(identifier: "name") { $0.name } }()
  static let age: Index<Developer, Int> = { Index(identifier: "age") { $0.age } }()

  static let documentDescriptor = DocumentDescriptor<Developer>(
    identifier: "Developer",
    indices: [
      name.eraseType(),
      age.eraseType()
    ]
  )

  static func deserializeDocument(from data: Data) throws -> Developer {
    fatalError()
  }

  func serializeDocument() throws -> Data {
    fatalError()
  }
}

struct Shipment {
  let barcode: String
  let status: Int
}

extension Shipment: Document {
  static let barcode: Index<Shipment, String> = { Index(identifier: "barcode") { $0.barcode } }()
  static let status: Index<Shipment, Int> = { Index(identifier: "status") { $0.status } }()

  static let documentDescriptor = DocumentDescriptor<Shipment>(
    identifier: "Shipment",
    indices: [
      barcode.eraseType(),
      status.eraseType()
    ]
  )

  static func deserializeDocument(from data: Data) throws -> Shipment {
    fatalError()
  }

  func serializeDocument() throws -> Data {
    fatalError()
  }
}

///////

class DocumentStoreTestsOld: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testExample() {

//      let rswiftDeveloper = Developer(name: "Mathijs", age: 29)

//      documentStore.write(handler: { _ in }) { transaction in
//        try transaction.add(document: rswiftDeveloper)
//        return .SaveChanges
//      }

//      documentStore!.read(handler: { result in fatalError() }) { (transaction) -> Developer? in
//        return try Query<Developer>()
//          .filtered { $0.age > 18 && $0.age < 30 }
//          .sorted { $0.age.ascending() }
//          .skipping(upTo: 3)
//          .limited(upTo: 1)
//          .execute(operation: transaction.fetchFirst)
//      }

      // Promise example
//      documentStore!.read { transaction in
//        try Query<Developer>()
//          .filtered { $0.age > 18 }
//          .sorted { $0.age.ascending() }
//          .execute(operation: transaction.fetchFirst)
//      }
//      .then { developer in
//        youngestAdultDeveloper.text = developer?.name ?? "No adults found."
//      }
    }

}
