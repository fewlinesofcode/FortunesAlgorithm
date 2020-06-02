# Circle

``` swift
public struct Circle
```

## Initializers

### `init?(p1:p2:p3:)`

Defines circle by three points
See: https://www.xarg.org/2018/02/create-a-circle-out-of-three-points/

``` swift
public init?(p1: Point, p2: Point, p3: Point)
```

### `init(center:radius:)`

Constructor. Defines a Circle by it's center and radius

``` swift
public init(center: Point, radius: Double)
```

#### Parameters

  - center: - center: Circle origin (center)
  - radius: - radius: Circle radius

## Properties

### `center`

``` swift
let center: Point
```

### `radius`

``` swift
let radius: Double
```

### `bottomPoint`

``` swift
var bottomPoint: Point
```
