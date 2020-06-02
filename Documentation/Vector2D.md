# Vector2D

``` swift
public struct Vector2D
```

## Initializers

### `init(dx:dy:)`

``` swift
public init(dx: Double, dy: Double)
```

## Properties

### `normal`

``` swift
var normal: Vector2D
```

### `point`

``` swift
var point: Site
```

### `dx`

``` swift
var dx
```

### `dy`

``` swift
var dy
```

### `magnitude`

``` swift
var magnitude: Double
```

## Methods

### `+(left:right:)`

``` swift
public static func +(left: Vector2D, right: Vector2D) -> Vector2D
```

### `-(left:right:)`

``` swift
public static func -(left: Vector2D, right: Vector2D) -> Vector2D
```

### `*(left:right:)`

``` swift
static func *(left: Double, right: Vector2D) -> Vector2D
```

### `*(left:right:)`

``` swift
static func *(left: Vector2D, right: Double) -> Vector2D
```
