import Foundation


public class VoronoiStatus {
    public var notVisitedSites = [Site]()
    public var visitedSites = [Site]()
    public var sweeplineY: Double = 0
    public var currentBreakpoint: Site?
    public var circles = [Circle]()
    public var upcomingCircleEvents = [Site]()
    public var clippedCells = [[Site]]()
    public var container: Rectangle?
    public var arcs = [(
        parabola: Parabola,
        lBound: Double,
        rBound: Double
    )]()
    public var box: Rectangle?
    public var potentialEdges = [LineSegment]()
    
    public init() { }
}
