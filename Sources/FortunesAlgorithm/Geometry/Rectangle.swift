//
//  Created by Oleksandr Glagoliev on 9/22/19.
//  Copyright © 2019 Oleksandr Glagoliev. All rights reserved.
//

import Foundation

// MARK: - Rectangle -
public struct Rectangle {
    public enum Edge: CaseIterable {
        case top
        case right
        case bottom
        case left
    }
    
    public var x: Double
    public var y: Double
    public var width: Double
    public var height: Double
    
    public init(origin: Site, size: Size) {
        self.x = origin.x
        self.y = origin.y
        self.width = size.width
        self.height = size.height
    }
    
    public var tl: Site {
        return Site(x: x, y: y)
    }
    
    public var bl: Site {
        return Site(x: tl.x, y: tl.y + height)
    }
    
    public var tr: Site {
        return Site(x: tl.x + width, y: tl.y)
    }
    
    public var br: Site {
        return Site(x: tl.x + width, y: tl.y + height)
    }
    
    public var origin: Site {
        return tl
    }
    
    public var size: Size {
        return Size(width: width, height: height)
    }
    
    public mutating func expandToContainPoint(_ p: Site, padding: Double = 20.0) {
        if p.x <= origin.x {
            width += abs(x - p.x + padding)
            x = p.x - padding
        }
        
        if p.y <= origin.y {
            height += abs(y - p.y + padding)
            y = p.y - padding
        }
        
        if p.x >= origin.x + width {
            width = p.x - x + padding
        }
        
        if p.y >= origin.y + height {
            height = p.y - y + padding
        }
    }
}

extension Rectangle {
    public func getLine(_ edge: Edge) -> LineSegment {
        switch edge {
        case .top:
            return LineSegment(a: tr, b: tl)
        case .right:
            return LineSegment(a: br, b: tr)
        case .bottom:
            return LineSegment(a: bl, b: br)
        case .left:
            return LineSegment(a: tl, b: bl)
        }
    }
    
    public func getEdges() -> [LineSegment] {
        [
            getLine(.top),
            getLine(.left),
            getLine(.right),
            getLine(.bottom)
        ]
    }
}


extension Rectangle {
    
    func contains(_ point: Site?) -> Bool {
        guard let point = point else { return false }
        return point.x >= tl.x && point.x <= tr.x && point.y >= tl.y && point.y <= br.y
    }
    
    
    func intersection(origin: Site, direction: Vector2D) -> (point: Site, edge: Rectangle.Edge) {
        var point: Site?
        var edge: Edge?
        var t = Double.infinity
        if (direction.dx > 0.0)
        {
            let right = getLine(.right)
            t = (right.a.x - origin.x) / direction.dx
            point = (origin.vector + t * direction).point
            edge = .right
        }
        else if (direction.dx < 0.0)
        {
            let left = getLine(.left)
            t = (left.a.x - origin.x) / direction.dx
            point = (origin.vector + t * direction).point
            edge = .left
        }
        if (direction.dy > 0.0)
        {
            let bottom = getLine(.bottom)
            let newT = (bottom.a.y - origin.y) / direction.dy
            if (newT < t) {
                point = (origin.vector + newT * direction).point
                edge = .bottom
            }
        }
        else if (direction.dy < 0.0)
        {
            let top = getLine(.top)
            let newT = (top.a.y - origin.y) / direction.dy
            if (newT < t) {
                point = (origin.vector + newT * direction).point
                edge = .top
            }
        }
        
        return (point!, edge!)
    }
    
    private func getNextCCW(_ edge: Edge) -> (edge: Edge, corner: Site) {
        switch edge {
            case .left: return (.bottom, bl)
            case .bottom: return (.right, br)
            case .right: return (.top, tr)
            case .top: return (.left, tl)
        }
    }
    
    func sideForPoint(p: Site) -> Edge? {
        let segments: [Edge: LineSegment] = [
            .top: getLine(.top),
            .right: getLine(.right),
            .bottom: getLine(.bottom),
            .left: getLine(.left)
        ]
        
        for (key, v) in segments {
            if v.containsPoint(p) {
                return key
            }
        }
        return nil
    }
    
    func ccwTraverse(startEdge: Edge, endEdge: Edge) -> [Site] {
        var points = [Site]()
        var edge = startEdge
        while edge != endEdge {
            let (e, p) = getNextCCW(edge)
            edge = e
            points.append(p)
        }
        return points
    }
    
    func getRectPolylineForCCW(_ start: Site, end: Site) -> [Site] {
        var result = [Site]()
        guard
            let startEdge = sideForPoint(p: start),
            let endEdge = sideForPoint(p: end) else {
                return result
        }
        if startEdge == endEdge {
            let segment = getLine(startEdge)
            if segment.a.distance(to: start) < segment.a.distance(to: end) {
                result = []
            } else {
                let next = getNextCCW(startEdge)
                result.append(next.corner)
                result.append(contentsOf: ccwTraverse(startEdge: next.edge, endEdge: startEdge))
            }
        } else {
            result.append(contentsOf: ccwTraverse(startEdge: startEdge, endEdge: endEdge))
        }
        return result
    }
    
    
}

extension Rectangle {
    public func toClipper() -> Clipper {
        Clipper(
            left: tl.x,
            right: tr.x,
            top: tr.y,
            bottom: br.y
        )
    }
}

extension Site {
    func distance(to point: Site) -> Double {
        let xDist = x - point.x
        let yDist = y - point.y
        return (xDist * xDist + yDist * yDist).squareRoot()
    }
}
