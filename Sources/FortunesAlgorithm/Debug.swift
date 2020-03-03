import Foundation

public protocol VoronoiDebugging: class {
    var notVisitedSites: [Site] { get set }
    var visitedSites: [Site] { get set }
    var sweeplineY: Double { get set }
    var currentBreakpoint: Site? { get set }
    var circles: [Circle] { get set }
    var upcomingCircleEvents: [Site] { get set }
    var container: Rectangle? { get set }
    var arcs: [
        (
            parabola: Parabola,
            lBound: Double,
            rBound: Double
        )
        ] { get set }
    var box: Rectangle? { get set }
    var potentialEdges: [LineSegment] { get set }
    var numSteps: Int? { get set }
    var curStep: Int { get set }
}
