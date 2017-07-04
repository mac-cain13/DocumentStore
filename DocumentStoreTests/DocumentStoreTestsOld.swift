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

//let documentStore = try? DocumentStore(
//  identifier: "TestDocumentStore",
//  documentDescriptors: DescriptorList()
//    .add(Developer.documentDescriptor)
//    .add(Shipment.documentDescriptor)
//)
//
struct Developer: Codable {
  let name: String
  let age: Int
}

extension Developer: Document {
  static let documentDescriptor = DocumentDescriptor<Developer>(
    name: "Developer",
    identifier: Identifier(keyPath: \.name),
    indices: [
      Index(name: "name", keyPath: \.name),
      Index(name: "age", keyPath: \.age)
    ]
  )
}

// Shorthands for keypath initializers
//extension Developer: Document {
//  static let documentDescriptor = DocumentDescriptor<Developer>(
//    name: "Developer",
//    identifier: \.name,
//    indices: [
//      AnyIndex(name: "name", keyPath: \.name),
//      AnyIndex(name: "age", keyPath: \.age)
//    ]
//  )
//}

//
struct Shipment: Document {
  let barcode: String
  let status: Int
  let weight: Double
}

extension Shipment {
  static let barcode: Identifier<Shipment, String> = { Identifier() { $0.barcode } }()
  static let status: Index<Shipment, Int> = { Index(name: "status") { $0.status } }()
  static let weight: Index<Shipment, Double> = { Index(name: "weight") { $0.weight } }()

  static let documentDescriptor = DocumentDescriptor<Shipment>(
    name: "Shipment",
    identifier: Shipment.barcode,
    indices: []
  )
}
//
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

//      try Query<Developer>()
//        .filtered { $0.age > 18 && $0.age < 30 }
//        .sorted { $0.age.ascending() }
//        .skipping(upTo: 3)
//        .limited(upTo: 1)
//        .delete()
//
      let documentStore: DocumentStore! = nil
      documentStore!.read(handler: { developers in print(developers) }) { transaction in
        try transaction.fetch(matching:
          Query<Developer>()
            .filtered { _ in \.age > 18 }
        )
      }

//      documentStore!.read {
//        try $0.fetchFirst(
//          Query<Developer>()
//            .filtered { $0.age > 18 && $0.age < 30 }
//            .sorted { $0.age.ascending() }
//            .skipping(upTo: 3)
//            .limited(upTo: 1)
//        )
//      }
//
//
//        return try Query<Developer>()
//          .filtered { $0.age > 18 && $0.age < 30 }
//          .sorted { $0.age.ascending() }
//          .skipping(upTo: 3)
//          .limited(upTo: 1)
//          .execute(operation: transaction.fetchFirst)
//      }
//      .then { developer in
//
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
