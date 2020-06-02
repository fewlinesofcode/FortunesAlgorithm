# PriorityQueue

A PriorityQueue takes objects to be pushed of any type that implements Comparable.
It will pop the objects in the order that they would be sorted. A pop() or a push()
can be accomplished in O(lg n) time. It can be specified whether the objects should
be popped in ascending or descending order (Max Priority Queue or Min Priority Queue)
at the time of initialization.

``` swift
public struct PriorityQueue<T: Comparable>
```

## Inheritance

`Collection`, `CustomDebugStringConvertible`, `CustomStringConvertible`, `IteratorProtocol`, `Sequence`

## Nested Type Aliases

### `Element`

``` swift
public typealias Element = T
```

### `Iterator`

``` swift
public typealias Iterator = PriorityQueue
```

### `Index`

``` swift
public typealias Index = Int
```

## Initializers

### `init(ascending:startingValues:)`

``` swift
public init(ascending: Bool = false, startingValues: [T] = [])
```

### `init(order:startingValues:)`

Creates a new PriorityQueue with the given ordering.

``` swift
public init(order: @escaping (T, T) -> Bool, startingValues: [T] = [])
```

#### Parameters

  - order: - order: A function that specifies whether its first argument should come after the second argument in the PriorityQueue.
  - startingValues: - startingValues: An array of elements to initialize the PriorityQueue with.

## Properties

### `heap`

``` swift
var heap
```

### `ordered`

``` swift
let ordered: (T, T) -> Bool
```

### `count`

How many elements the Priority Queue stores

``` swift
var count: Int
```

### `isEmpty`

true if and only if the Priority Queue is empty

``` swift
var isEmpty: Bool
```

### `startIndex`

``` swift
var startIndex: Int
```

### `endIndex`

``` swift
var endIndex: Int
```

### `description`

``` swift
var description: String
```

### `debugDescription`

``` swift
var debugDescription: String
```

## Methods

### `push(_:)`

Add a new element onto the Priority Queue. O(lg n)

``` swift
public mutating func push(_ element: T)
```

#### Parameters

  - element: - element: The element to be inserted into the Priority Queue.

### `pop()`

Remove and return the element with the highest priority (or lowest if ascending). O(lg n)

``` swift
public mutating func pop() -> T?
```

#### Returns

The element with the highest priority in the Priority Queue, or nil if the PriorityQueue is empty.

### `remove(_:)`

Removes the first occurence of a particular item. Finds it by value comparison using ==. O(n)
Silently exits if no occurrence found.

``` swift
public mutating func remove(_ item: T)
```

#### Parameters

  - item: - item: The item to remove the first occurrence of.

### `removeAll(_:)`

Removes all occurences of a particular item. Finds it by value comparison using ==. O(n)
Silently exits if no occurrence found.

``` swift
public mutating func removeAll(_ item: T)
```

#### Parameters

  - item: - item: The item to remove.

### `peek()`

Get a look at the current highest priority item, without removing it. O(1)

``` swift
public func peek() -> T?
```

#### Returns

The element with the highest priority in the PriorityQueue, or nil if the PriorityQueue is empty.

### `clear()`

Eliminate all of the elements from the Priority Queue.

``` swift
public mutating func clear()
```

### `sink(_:)`

``` swift
private mutating func sink(_ index: Int)
```

### `swim(_:)`

``` swift
private mutating func swim(_ index: Int)
```

### `next()`

``` swift
mutating public func next() -> Element?
```

### `makeIterator()`

``` swift
public func makeIterator() -> Iterator
```

### `index(after:)`

``` swift
public func index(after i: PriorityQueue.Index) -> PriorityQueue.Index
```
