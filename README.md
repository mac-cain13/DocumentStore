# DocumentStore
A document database with the typesafety and ease of use you want and the querying and indexing that you need.

- Store data without defining schemas, tables or object models
- The typesafety you're used to with Swift (No vars, forced unwrapping, casting or NSObjects)
- Indexing makes efficient sorting and filtering possible
- Non-blocking operations that run on a background thread by default
- 100% client side, free to use open source database under MIT license

## How does it work?

### Define a document

```swift
struct TodoItem: Document, Codable {
  static let documentDescriptor = DocumentDescriptor<TodoItem>(name: "TodoItem",
                                                               identifier: Identifier(keyPath: \.id),
                                                               indices: [
                                                                 Index(name: "completed", keyPath: \.completed)
                                                               ])

  let id: Int
  let text: String
  let completed: Bool
}
```

### Create a database

```swift
let documentStore = try DocumentStore(identifier: "TodoStore",
                                      documentDescriptors: [TodoItem.documentDescriptor])
```

### Insert a document

```swift
let todoItem = TodoItem(id: 1, text: "Give DocumentStore a try", completed: false)

documentStore.write(handler: { result in
  if case let .failure(error) = result {
    fatalError(error)
  }
}, actions: { transaction in
  try transaction.insert(document: todoItem)
  return .saveChanges
})
```

### Query for documents

```swift
let uncompletedQuery = Query<TodoItem>()
  .sorted(by: \.id, order: .ascending)
  .filtered { _ in !\.completed }

documentStore.read(handler: { result in
  switch result {
  case let .success(todoItems):
    debugPrint(todoItems)
  case let .failure(error):
    fatalError(error)
  }
}, actions: { transaction in
  try transaction.fetch(matching: uncompletedQuery)
})
```

## When to use?

DocumentStore is a good fit when you want to:
- persist items to disk
- be able to sort and filter them
- ease of use

## Installation

_TODO:_ Explain ways to use this in your project.

## Limits

DocumentStore has no hard limits and is optimized for a few thousands of objects that are small to medium sized (up to ±1MB). Very big objects or a big number of documents may start to slow things down.

## License

[DocumentStore](https://github.com/mac-cain13/DocumentStore) is created by [Mathijs Kadijk](https://github.com/mac-cain13) and released under a [MIT License](License).
