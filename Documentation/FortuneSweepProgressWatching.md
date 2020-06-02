# FortuneSweepProgressWatching

``` swift
public protocol FortuneSweepProgressWatching: class
```

## Inheritance

`class`

## Requirements

## step

Depicts current step of an algorithm

``` swift
var step: Int
```

## prepare(sites:clipper:)

Called when algorithm is ready to work

``` swift
func prepare(sites: Set<Site>, clipper: Rectangle)
```

### Parameters

  - sites: - sites: Same as Fortunes Algorithm input
  - clipper: - clipper: Clipping rectangle

## updateSweepline(y:)

Called when sweepline changes position

``` swift
func updateSweepline(y: Double)
```

### Parameters

  - y: - y: New sweepline Y position

## siteEvent(site:)

Called when Site Event occured

``` swift
func siteEvent(site: Site)
```

### Parameters

  - site: - site: Visited site

## circleEvent(point:)

Called when Circle Event occured

``` swift
func circleEvent(point: Point)
```

### Parameters

  - site: - site: Visited site

## updateContainer(rectangle:)

Called when bounding rectangle is changed

``` swift
func updateContainer(rectangle: Rectangle)
```

### Parameters

  - rectangle: - rectangle: New Bounding rectangle

## updateCurentBreakpoint(point:)

Called when new breakpoint occured

``` swift
func updateCurentBreakpoint(point: Point?)
```

### Parameters

  - point: - point: Breakpoint

## updateBeachline(arcs:)

Called when beachline is updated

``` swift
func updateBeachline(arcs: [BeachlineSegment])
```

### Parameters

  - arcs: - arcs: Arcs, currently present in the Beachline

## addUpcomingCircleEvent(circle:)

Called when upcoming circle event is added to the Event Queue

``` swift
func addUpcomingCircleEvent(circle: Circle)
```

### Parameters

  - circle: - circle: Circle event circle

## removeFalseAlarmCircleEvent(circle:)

Called when Circle event is removed from Event Queue

``` swift
func removeFalseAlarmCircleEvent(circle: Circle)
```

### Parameters

  - circle: - circle: Circle event circle

## createVertex(vertex:)

Called when new Vertex is created

``` swift
func createVertex(vertex: Vertex)
```

### Parameters

  - vertex: - vertex: Vertex

## createCell(cell:)

Called when new Cell is added to the diagram

``` swift
func createCell(cell: Cell)
```

### Parameters

  - cell: - cell: Cell

## addHalfEdges(hes:)

Called when HalfEdges are added to the diagram

``` swift
func addHalfEdges(hes: [HalfEdge])
```

### Parameters

  - hes: - hes: List of recently added HalfEdges

## boundingDone()

Called when Cells bounding is done

``` swift
func boundingDone()
```

## workDone()

Called when algorithm finished working

``` swift
func workDone()
```
