# Rectangle

``` swift
public struct Rectangle
```

## Initializers

### `init(origin:size:)`

``` swift
public init(origin: Site, size: Size)
```

## Properties

### `x`

``` swift
var x: Double
```

### `y`

``` swift
var y: Double
```

### `width`

``` swift
var width: Double
```

### `height`

``` swift
var height: Double
```

### `tl`

``` swift
var tl: Site
```

### `bl`

``` swift
var bl: Site
```

### `tr`

``` swift
var tr: Site
```

### `br`

``` swift
var br: Site
```

### `origin`

``` swift
var origin: Site
```

### `size`

``` swift
var size: Size
```

## Methods

### `expandToContainPoint(_:padding:)`

``` swift
public mutating func expandToContainPoint(_ p: Site, padding: Double = 20.0)
```

### `getLine(_:)`

``` swift
public func getLine(_ edge: Edge) -> LineSegment
```

### `getEdges()`

``` swift
public func getEdges() -> [LineSegment]
```

### `rect(from:with:)`

``` swift
public static func rect(from sourceRect: Rectangle, with padding: Double) -> Rectangle
```

### `contains(_:)`

``` swift
func contains(_ point: Site?) -> Bool
```

### `intersection(origin:direction:)`

``` swift
func intersection(origin: Site, direction: Vector2D) -> (point: Site, edge: Rectangle.Edge)
```

### `getNextCCW(_:)`

``` swift
private func getNextCCW(_ edge: Edge) -> (edge: Edge, corner: Site)
```

### `sideForPoint(p:)`

``` swift
func sideForPoint(p: Site) -> Edge?
```

### `ccwTraverse(startEdge:endEdge:)`

``` swift
func ccwTraverse(startEdge: Edge, endEdge: Edge) -> [Site]
```

### `getRectPolylineForCCW(_:end:)`

``` swift
func getRectPolylineForCCW(_ start: Site, end: Site) -> [Site]
```

### `toClipper()`

``` swift
public func toClipper() -> Clipper
```
