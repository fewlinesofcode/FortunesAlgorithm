// MIT License
//
// Copyright (c) 2020 Oleksandr Glagoliev
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.


import Foundation

// MARK: - Circle
public struct Circle {
    public let center: Point
    public let radius: Double
    
    /// Defines circle by three points
    /// See: https://www.xarg.org/2018/02/create-a-circle-out-of-three-points/
    public init?(p1: Point, p2: Point, p3: Point) {
        let x1 = p1.x
        let y1 = p1.y
        let x2 = p2.x
        let y2 = p2.y
        let x3 = p3.x
        let y3 = p3.y
        
        let a = x1 * (y2 - y3) - y1 * (x2 - x3) + x2 * y3 - x3 * y2
        
        let b =
              (x1 * x1 + y1 * y1) * (y3 - y2)
            + (x2 * x2 + y2 * y2) * (y1 - y3)
            + (x3 * x3 + y3 * y3) * (y2 - y1)
        
        let c =
              (x1 * x1 + y1 * y1) * (x2 - x3)
            + (x2 * x2 + y2 * y2) * (x3 - x1)
            + (x3 * x3 + y3 * y3) * (x1 - x2)
        
        if a == 0 {
            return nil
        }
        
        let x = -b / (2 * a)
        let y = -c / (2 * a)
        
        center = Point(x: x, y: y)
        radius = hypot(x - x1, y - y1)
    }
    
    
    /// Constructor. Defines a Circle by it's center and radius
    /// - Parameters:
    ///   - center: Circle origin (center)
    ///   - radius: Circle radius
    public init(center: Point, radius: Double) {
        self.center = center
        self.radius = radius
    }
}

extension Circle {
    // Returns a point with maximum *Y* coordinate
    public var bottomPoint: Point {
        Point(
            x: center.x,
            y: center.y + radius
        )
    }
}
