import UIKit

extension CGPoint {
    public var point: Site {
        Site(x: Double(x), y: Double(y))
    }
}

extension Site {
    public var cgPoint: CGPoint {
        CGPoint(x: x, y: y)
    }
}

extension CGContext {
    public func drawSite(_ site: Site, visited: Bool) {
        drawCircle(
            origin: site.cgPoint,
            radius: 2.0,
            strokeColor: .black,
            fillColor: visited
                ? .visitedSite
                : .notVisitedSite
        )
    }
    
    public func drawBreakpoint(_ point: Site) {
        drawCross(point, size: 4.0)
    }
    
    public func drawUpcomingCircleEvent(_ point: Site) {
        drawCross(point, size: 4.0, strokeColor: .circleEventPoint)
    }
    
    public func drawArc(_ arc: (start: Site, cp: Site, end: Site)) {
        drawQuadBezier(
            from: arc.start.cgPoint,
            to: arc.end.cgPoint,
            cp: arc.cp.cgPoint,
            strokeColor: .lightGray,
            strokeWidth: 2
        )
    }
        
    public func drawVertex(_ point: Site) {
        drawCircle(
            origin: point.cgPoint,
            radius: 2.0,
            strokeColor: .clear,
            fillColor: .black
        )
    }
    
    
    
}

