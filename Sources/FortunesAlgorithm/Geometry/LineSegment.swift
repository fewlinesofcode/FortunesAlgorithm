//
//  LineCut.swift
//  FortuneSweep
//
//  Created by Oleksandr Glagoliev on 9/21/19.
//  Copyright © 2019 Oleksandr Glagoliev. All rights reserved.
//

/*
MIT License

Copyright (c) 2020 Oleksandr Glagoliev

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

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
    
    func length() -> Double {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return (xDist * xDist + yDist * yDist).squareRoot()
    }
}
