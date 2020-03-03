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
    public var a: Site
    public var b: Site
    
    public init(a: Site, b: Site) {
        self.a = a
        self.b = b
    }
}

public extension LineSegment {
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
}
