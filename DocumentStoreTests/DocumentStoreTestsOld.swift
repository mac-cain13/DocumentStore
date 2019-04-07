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

let documentStore: DocumentStore! = try? DocumentStore(identifier: "MyStore",
                                                       documentDescriptors: [Message.documentDescriptor])

struct Message: Document, Codable {
  static let documentDescriptor = DocumentDescriptor<Message>(name: "Message",
                                                              identifier: Identifier(keyPath: \.id),
                                                              indices: [
                                                                Index(name: "senderName", keyPath: \.sender.name),
                                                                Index(name: "receiverName", keyPath: \.receiver.name),
                                                                Index(name: "sentDate", keyPath: \.sentDate)
                                                              ])

  let id: Int
  let read: Bool
  let sentDate: Date
  let sender: Person
  let receiver: Person
  let subject: String?
  let text: String
}

struct Person: Codable {
  let id: Int
  let name: String
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

      let message = Message(id: 1, read: false, sentDate: Date(), sender: Person(id: 1, name: "John Appleseed"), receiver: Person(id: 2, name: "Jane Bananaseed"), subject: nil, text: "Hi!\nHow about dinner?")

      documentStore.write(handler: { result in
        if case let .failure(error) = result {
          fatalError("\(error)")
        }
      }) { transaction in
        try transaction.insert(document: message, mode: .addOrReplace)
        return .saveChanges
      }

      /* Promise version */
      //      documentStore.write { transaction in
      //        try transaction.insert(document: message, mode: .addOrReplace)
      //        return .saveChanges
      //      }
      //      .then {
      //        // Hooray!
      //      }
      //      .trap { error in
      //        fatalError("\(error)")
      //      }

      let newestMessageQuery = Query<Message>()
        .sorted(by: \Message.sentDate, order: .ascending)

      documentStore.read(handler: { result in
        if case let .success(.some(message)) = result {
          print(message.id)
        }
      }) { try $0.fetchFirst(matching: newestMessageQuery) }

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

//      let documentStore: DocumentStore! = nil
//      documentStore!.read(handler: { developers in print(developers) }) { transaction in
//        try transaction.fetch(matching:
//          Query<Developer>()
//            .filtered { _ in \.age > 18 }
//            .sorted { _ in (\Developer.age).ascending() }
//        )
//      }

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
