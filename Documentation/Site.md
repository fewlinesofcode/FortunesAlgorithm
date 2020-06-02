# Site

Represent the Point in 2D Cartesian coordinate system

``` swift
public struct Site
```

## Inheritance

`CustomStringConvertible`, `Hashable`

## Initializers

### `init(x:y:)`

``` swift
public init(x: Double, y: Double)
```

## Properties

### `vector`

``` swift
var vector: Vector2D
```

### `satellite`

``` swift
var satellite: Any?
```

### `x`

``` swift
var x: Double
```

### `y`

``` swift
var y: Double
```

### `description`

``` swift
var description: String
```

## Methods

### `distance(to:)`

``` swift
func distance(to point: Site) -> Double
```

### `==(lhs:rhs:)`

``` swift
public static func ==(lhs: Site, rhs: Site) -> Bool
```

### `hash(into:)`

``` swift
public func hash(into hasher: inout Hasher)
```
