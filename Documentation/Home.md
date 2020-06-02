# Types

  - [PriorityQueue](/PriorityQueue):
    A PriorityQueue takes objects to be pushed of any type that implements Comparable.
    It will pop the objects in the order that they would be sorted. A pop() or a push()
    can be accomplished in O(lg n) time. It can be specified whether the objects should
    be popped in ascending or descending order (Max Priority Queue or Min Priority Queue)
    at the time of initialization.
  - [Diagram](/Diagram)
  - [Cell](/Cell):
    Stores pointer to:
    • `outerComponent` linked list (looped when diagram is built)
    • `site` - pointer to the site
  - [HalfEdge](/HalfEdge):
    The half‐edge record of a half‐edge e stores pointer to:
    • Origin(e)
    • Twin of e, e.twin or twin(e)
    • The face to its left (IncidentFace(e))
    • Next(e): next half‐edge on the boundary of IncidentFace(e)
    • Previous(e): previous half‐edge
  - [FortuneSweep](/FortuneSweep)
  - [BeachlineSegment](/BeachlineSegment)
  - [FortuneSweppLogLevel](/FortuneSweppLogLevel):
    \<\#Description\#\>
  - [Circle](/Circle)
  - [Clipper](/Clipper)
  - [LineSegment](/LineSegment)
  - [Parabola](/Parabola)
  - [Rectangle](/Rectangle)
  - [Rectangle.Edge](/Rectangle_Edge)
  - [Site](/Site):
    Represent the Point in 2D Cartesian coordinate system
  - [Size](/Size):
    Represents the size of Rectangular object
  - [Vector2D](/Vector2D)

# Protocols

  - [FortuneSweepLogging](/FortuneSweepLogging)
  - [FortuneSweepProgressWatching](/FortuneSweepProgressWatching)

# Global Typealiases

  - [Vertex](/Vertex):
    The vertex record of a vertex v stores the coordinates of v.
    It also stores a pointer IncidentEdge(v) to an arbitrary half‐edge that has v as its origin
  - [Point](/Point)
  - [LiangBarskyResult](/LiangBarskyResult)

# Global Functions

  - [lb\_clip(\_:clipper:)](/lb_clip\(_:clipper:\))
