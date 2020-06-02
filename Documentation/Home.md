# Types

  - [PriorityQueue](/PriorityQueue.md):
    A PriorityQueue takes objects to be pushed of any type that implements Comparable.
    It will pop the objects in the order that they would be sorted. A pop() or a push()
    can be accomplished in O(lg n) time. It can be specified whether the objects should
    be popped in ascending or descending order (Max Priority Queue or Min Priority Queue)
    at the time of initialization.
  - [Diagram](/Diagram.md)
  - [Cell](/Cell.md):
    Stores pointer to:
    • `outerComponent` linked list (looped when diagram is built)
    • `site` - pointer to the site
  - [HalfEdge](/HalfEdge.md):
    The half‐edge record of a half‐edge e stores pointer to:
    • Origin(e)
    • Twin of e, e.twin or twin(e)
    • The face to its left (IncidentFace(e))
    • Next(e): next half‐edge on the boundary of IncidentFace(e)
    • Previous(e): previous half‐edge
  - [FortuneSweep](/FortuneSweep.md)
  - [BeachlineSegment](/BeachlineSegment.md)
  - [FortuneSweppLogLevel](/FortuneSweppLogLevel.md):
    \<\#Description\#\>
  - [Circle](/Circle.md)
  - [Clipper](/Clipper.md)
  - [LineSegment](/LineSegment.md)
  - [Parabola](/Parabola.md)
  - [Rectangle](/Rectangle.md)
  - [Rectangle.Edge](/Rectangle_Edge.md)
  - [Site](/Site.md):
    Represent the Point in 2D Cartesian coordinate system
  - [Size](/Size.md):
    Represents the size of Rectangular object
  - [Vector2D](/Vector2D.md)

# Protocols

  - [FortuneSweepLogging](/FortuneSweepLogging.md)
  - [FortuneSweepProgressWatching](/FortuneSweepProgressWatching.md)

# Global Typealiases

  - [Vertex](/Vertex.md):
    The vertex record of a vertex v stores the coordinates of v.
    It also stores a pointer IncidentEdge(v) to an arbitrary half‐edge that has v as its origin
  - [Point](/Point.md)
  - [LiangBarskyResult](/LiangBarskyResult.md)

# Global Functions

  - [lb\_clip(\_:clipper:)](/lb_clip\(_:clipper:\).md)
