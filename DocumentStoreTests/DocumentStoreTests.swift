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

let documentStore = DocumentStore(
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
    identifier: "Artist",
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

class DocumentStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {

//      let rswiftDeveloper = Developer(name: "Mathijs", age: 29)

//      documentStore.write(handler: { _ in }) { transaction in
//        try transaction.add(document: rswiftDeveloper)
//        return .SaveChanges
//      }

      documentStore.read(handler: { _ in }) {
        return try Developer.query(with: $0)
          .filter { $0.name == "Mathijs" }
          .first()
      }

    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
