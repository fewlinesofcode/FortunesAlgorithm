# FortuneSweep

``` swift
public class FortuneSweep
```

## Initializers

### `init(logger:watcher:)`

Initialises new FortuneSweep instance
NB: `logger` and especially `watcher` will affect performance\!
Use them only for debug purposes\!

``` swift
public init(logger: FortuneSweepLogging? = nil, watcher: FortuneSweepProgressWatching? = nil)
```

#### Parameters

  - logger: - logger: Optional. Calls `log` function when importand events happen
  - watcher: - watcher: Optional. **Affects performance\!** Tracks diagram building process. May be used for visualisation as it includes useful scaffolding.

## Properties

### `eventQueue`

Service Data Structures

``` swift
var eventQueue: PriorityQueue<Event>!
```

### `beachline`

``` swift
var beachline: Beachline!
```

### `sweepLineY`

``` swift
var sweepLineY: Double
```

### `firstSiteY`

``` swift
var firstSiteY: Double?
```

### `container`

``` swift
var container: Rectangle!
```

### `clipper`

``` swift
var clipper: Rectangle!
```

### `logger`

Debug Data structures

``` swift
var logger: FortuneSweepLogging?
```

### `watcher`

``` swift
var watcher: FortuneSweepProgressWatching?
```

### `currentStep`

``` swift
var currentStep: Int
```

### `isTerminated`

``` swift
var isTerminated: Bool!
```

### `diagram`

Result Data Structure

``` swift
var diagram: Diagram!
```

## Methods

### `compute(sites:diagram:clippingRect:maxStepsCount:)`

``` swift
public func compute(sites: Set<Site>, diagram: inout Diagram, clippingRect: Rectangle, maxStepsCount: Int = -1) -> Bool
```

### `debug_step()`

Runs one step of an algorithm

``` swift
func debug_step() -> Bool
```

### `step()`

Performs one step of the algorithm

``` swift
private func step()
```

1.  Pop an event from the event queue
2.  Check the event type and process the event appropriately

### `processSiteEvent(_:)`

Processes **Site event** and performs all the necessary actions

``` swift
private func processSiteEvent(_ event: Event)
```

#### Parameters

  - event: - event: **Site Event** to process

### `createVertex(_:removedArc:)`

When Circle event took place we must create a **Vertex** record in the Diagram.

``` swift
private func createVertex(_ vertex: Vertex, removedArc: Arc)
```

#### Parameters

  - vertex: - vertex: Vertex coordinate (e.g. Circle event center)
  - removedArc: - removedArc: The arc that will be removed from the **Beachline** after the Circle event

### `processCircleEvent(_:)`

Processes circle event and performs all the necessary actions

``` swift
private func processCircleEvent(_ event: Event)
```

#### Parameters

  - event: - event: **Circle Event**

### `createCircleEvent(_:)`

Creates circle event for the coresponding **Arc** in the **Beachline**
Adds **Circle Event** into **Priority Queue**
Sets ponters between **Circle Event** and **Arc**

``` swift
private func createCircleEvent(_ arc: Arc)
```

#### Parameters

  - arc: - arc: **Beachline** arc to add event
  - circle: - circle: Circle represented by three points

### `removeCircleEvent(_:)`

Removes circle event from the **Priority Queue** and removes event from the **Arc**

``` swift
private func removeCircleEvent(_ arc: Arc?)
```

#### Parameters

  - arc: - arc: **Arc** to strip from **Circle Event**

### `terminate()`

Algorithm termination

``` swift
private func terminate()
```

1.  Bound incomplete arcs to Maximum rectangle
2.  Complete incomplete cells
3.  Clip cells to clipping rectangle

### `completeIncompleteCell(_:)`

Some of the cells will not be completed (Are not looped linked list of half-edges)

``` swift
private func completeIncompleteCell(_ cell: Cell)
```

#### Parameters

  - cell: - cell: cell to complete

### `boundIncompleteArc(_:)`

Bounds incomplete arcs to the maximum rectangle
Maximum rectangle is a `Rectangle` containing ALL diagram vertexes. It is expanded as

``` swift
private func boundIncompleteArc(_ arc: Arc)
```

#### Parameters

  - arc: - arc: `Arc` from the beachline

### `clipCell(_:clippingRect:)`

Clips cell agains clipping `Rectangle`. There are few limitations:

``` swift
private func clipCell(_ cell: Cell, clippingRect: Rectangle)
```

#### Parameters

  - cell: - cell: cell to clip
  - clippingRect: - clippingRect: clipping rect

### `halfEdgesChain(cell:clippingRect:start:end:)`

Returns linked list of half-edges belonging to the clipping rect (maximum 4) represented as a pair

``` swift
private func halfEdgesChain(cell: Cell, clippingRect: Rectangle, start: Site, end: Site) -> (HalfEdge, HalfEdge)?
```

#### Parameters

  - cell: - cell: half-edges owning `Cell`
  - clippingRect: - clippingRect: Clipping rectangle
  - start: - start: head origin
  - end: - end: tail destination

### `getBoxIntersection(_:_:_:)`

Finds the intersection point for the bisector of the Line Segment defined by two points and Rectangle

``` swift
private func getBoxIntersection(_ p1: Site, _ p2: Site, _ rectangle: Rectangle) -> Site
```

#### Parameters

  - p1: - p1: Point
  - p2: - p2: Point
  - rectangle: - rectangle: Rectangle

### `makeTwins(_:_:)`

When the Cell has common edge with another cell, thir corresponding **HalfEdges** are twins.
It means they have a pointer to each other and `a.origin == b.destination` and vice versa
This helper sets appropriate pointers between half edges

``` swift
private func makeTwins(_ a: HalfEdge?, _ b: HalfEdge?)
```

### `connect(prev:next:)`

Each cell is represented as **Doubly connected** linked list of **HalfEdges**
This helper connects two half edges appropriately

``` swift
private func connect(prev: HalfEdge?, next: HalfEdge?)
```

### `checkCircleEvent(left:mid:right:)`

Receives three arcs as an input and returns a circle, if the arc's points are not collinear and converging.
Convergence means that at some point `mid` arc will be removed (Circle event will take place)
Keep in mind that the fact that three points define a circle is not enough for circle event to take place

``` swift
private func checkCircleEvent(left: Arc?, mid: Arc, right: Arc?) -> Circle?
```

#### Parameters

  - left: - left: left arc
  - mid: - mid: middle arc
  - right: - right: right arc
