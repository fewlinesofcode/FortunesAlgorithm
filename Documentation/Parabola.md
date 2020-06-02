# Parabola

``` swift
public struct Parabola
```

## Initializers

### `init(focus:directrixY:)`

Constructor that defines parabola by the focus and the directrix that is **Parallel** to *X-axis*\!

``` swift
public init(focus: Site, directrixY: Double)
```

#### Parameters

  - focus: - focus: Parabola focus
  - directrixY: - directrixY: Directix *Y*

## Properties

### `focus`

``` swift
var focus: Site
```

### `directrixY`

``` swift
var directrixY: Double
```

### `standardForm`

Converts parabola to standart form (ax^2 + by \* c)

``` swift
var standardForm: (a: Double, b: Double, c: Double)
```

## Methods

### `resolve(x:)`

Resolves parabola equation against given *X*

``` swift
public func resolve(x: Double) -> Double
```

#### Parameters

  - x: - x: given x

### `toQuadBezier(minX:maxX:)`

Quadrativ Bezier representation of the Parabola clipped by *X*

``` swift
public func toQuadBezier(minX: Double, maxX: Double) -> (start: Site, cp: Site, end: Site)
```

#### Parameters

  - minX: - minX: Min *X* clippling point
  - maxX: - maxX: Max *X* clippling point

### `intersectionX(_:)`

*X* coordinate of the intersection with other Parabola (if present)

``` swift
public func intersectionX(_ parabola: Parabola) -> Double?
```

#### Parameters

  - parabola: - parabola: other parabola
