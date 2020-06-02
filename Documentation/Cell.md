# Cell

Stores pointer to:
• `outerComponent` linked list (looped when diagram is built)
• `site` - pointer to the site

``` swift
public class Cell
```

## Initializers

### `init(site:)`

``` swift
public init(site: Site)
```

## Properties

### `satellite`

``` swift
var satellite: Any?
```

### `outerComponent`

``` swift
var outerComponent: HalfEdge?
```

### `site`

``` swift
var site: Site
```

## Methods

### `hullVerticesCCW()`

Returns hell vertices of the cell

``` swift
func hullVerticesCCW() -> [Vertex]
```

### `neighbours()`

Returns all the neighbours of specific cell

``` swift
func neighbours() -> [Cell]
```
