# FortunesAlgorithm

`FortunesAlgorithm` is a Swift package for building Voronoi diagrams using Steven Fortune's algorithm. Algorithm guarantees `O(n log n)` worst-case running time and uses `O(n)` space.

You can learn more about the project using [Documentation](https://github.com/fewlinesofcode/FortunesAlgorithm/blob/master/Documentation/Home.md)

# Installing

`FortunesAlgorithm` can be installed as any other Swift package. Add the following to the `dependencies` section of your `Package.swift`:

```
.package(url: "https://github.com/fewlinesofcode/FortunesAlgorithm", from: "1.0.0")
```

# Basic Usage

1. Add package dependency
2. Import `import FortunesAlgorithm`
3. Add diagram computation code in appropriate place: 

```
let fortuneSweep = FortunesAlgorithm()
var diagram = Diagram()
let clippingRect = Rectangle(
            origin: Vertex(x: 20, y: 20),
            size: Size(width: 100, height: 100)
        )
var sites = Set<Site>([Site(x: 10, y: 10), Site(x: 50, y: 50)/* Generate sites you need ... */])
fortuneSweep.compute(
            sites: sites,
            diagram: &diagram,
            clippingRect: clippingRect
        )
        
// `diagram.cells` now contains doubly linked list of `HalfEdges` and their twins allowing you to continue diagram usage drawing.
```

# Literature

### Must read:
1. "Computational Geometry Algorithms and Applications. Third Edition" by Mark de Berg, Otfried Cheong Marc van Kreveld, Mark Overmars (Voronoi diagrams section)
2. "Introduction to Algorithms. Third Edition" by Thomas H. Cormen, Charles E. Leiserson, Ronald L. Rivest, Clifford Stein (RedBlack Trees section)
3. [A Sweepline Algorithm for Voronoi Diagrams](http://www.wias-berlin.de/people/si/course/files/Fortune87-SweepLine-Voronoi.pdf) - Steven Fortune's paper

### This project would not be possible without following articles:

1. ([Fortunes Algorithm. Part 1](https://jacquesheunis.com/post/fortunes-algorithm/) and [Fortunes Algorithm Part 2](https://jacquesheunis.com/post/fortunes-algorithm-implementation/) by Jacques Heunis (@jacquesh)
2. [Fortune's algorithm, the details](https://pvigier.github.io/2018/11/18/fortune-algorithm-details.html) by Pierre Vigier (@pvigier)

# Contact

Feel free to ask questions, report bugs and submit pull requests!

You can contact me by email: [oglagoliev@gmail.com](oglagoliev@gmail.com) or 
follow me on Twitter: [@fewlinesofcode](https://twitter.com/fewlinesofcode) 
