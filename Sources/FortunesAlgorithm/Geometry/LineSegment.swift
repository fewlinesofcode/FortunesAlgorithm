//
//  LineCut.swift
//  FortuneSweep
//
//  Created by Oleksandr Glagoliev on 9/21/19.
//  Copyright © 2019 Oleksandr Glagoliev. All rights reserved.
//

import Foundation

// MARK: - LineSegment -

public struct LineSegment {
    var a: Site
    var b: Site
    
    public init(a: Site, b: Site) {
        self.a = a
        self.b = b
    }
}

extension LineSegment: CustomStringConvertible {
    public var description: String {
        return "A(\(a.x),\(a.y))) B(\(b.x),\(b.y)))"
    }
}

enum SegmentIntersection {
    case none
    case point(Site)
    case lineSegment(LineSegment)
}

public extension LineSegment {
    // Returns `Line` defined by Interval
    var line: Line {
        return Line(p1: a, p2: b)
    }
    
    var midPoint: Site {
        Site(
            x: (b.x + a.x) / 2,
            y: (b.y + a.y) / 2
        )
    }
    
    func containsPoint(_ point: Site) -> Bool {
        var k, c: Double
        
        if abs(b.x - a.x) < eps {
            return (
                abs(point.x - a.x) < eps
                && point.y >= min(a.y, b.y)
                && a.y <= max(a.y, b.y)
            )
        }
        
        k = (b.y - a.y) / (b.x - a.x)
        c = a.y - k * a.x
        
        return abs(point.y - (point.x * k + c)) < eps
    }
    
    func parallelSegmentCCW(at distance: Double) -> (left: LineSegment, right: LineSegment) {
        let a1: Double = a.x - b.x
        let a2: Double = a.y - b.y
        
        let v1: Double = 1 // any non-zero
        let v2: Double = (-a1 / a2) * v1
        
        let m = (v1*v1 + v2*v2).squareRoot()
        let nv1 = v1 / m * distance
        let nv2 = v2 / m * distance
        return (
            left: LineSegment(
                a: Site(x: a.x + nv1, y: a.y + nv2),
                b: Site(x: b.x + nv1, y: b.y + nv2)
            ),
            right: LineSegment(
                a: Site(x: a.x - nv1, y: a.y - nv2),
                b: Site(x: b.x - nv1, y: b.y - nv2)
            )
        )
    }
}
