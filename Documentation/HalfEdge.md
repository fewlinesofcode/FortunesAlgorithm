# HalfEdge

The half‐edge record of a half‐edge e stores pointer to:
• Origin(e)
• Twin of e, e.twin or twin(e)
• The face to its left (IncidentFace(e))
• Next(e): next half‐edge on the boundary of IncidentFace(e)
• Previous(e): previous half‐edge

``` swift
public class HalfEdge
```

## Properties

### `satellite`

``` swift
var satellite: Any?
```

### `origin`

``` swift
var origin: Vertex?
```

### `destination`

``` swift
var destination: Vertex?
```

### `twin`

``` swift
var twin: HalfEdge?
```

### `incidentFace`

``` swift
var incidentFace: Cell?
```

### `prev`

``` swift
var prev: HalfEdge?
```

### `next`

``` swift
var next: HalfEdge?
```

## Methods

### `toSegment()`

``` swift
func toSegment() -> LineSegment?
```
