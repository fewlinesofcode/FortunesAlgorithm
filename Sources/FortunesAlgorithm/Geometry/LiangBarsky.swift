//
//  LiangBarsky.swift
//  FortunesAlgorithm
//
//  Created by Oleksandr Glagoliev on 2/16/20.
//  Copyright © 2020 Oleksandr Glagoliev. All rights reserved.
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

// MARK: - Clipper -
public struct Clipper {
    let left: Double
    let right: Double
    let top: Double
    let bottom: Double
    
    enum Edge: CaseIterable {
        case left
        case right
        case top
        case bottom
    }
}



// - Liang-Barsky function by Daniel White
//   http://www.skytopia.com/project/articles/compsci/clipping.html
// - Paper
//   https://www.cs.helsinki.fi/group/goa/viewing/leikkaus/intro.html
public typealias LiangBarskyResult = (isOriginClipped: Bool, isDestinationClipped: Bool, resultSegment: LineSegment?)
public func lb_clip(_ line: LineSegment, clipper: Clipper) -> LiangBarskyResult {
    var t0: Double = 0.0
    var t1: Double = 1.0
    let dx: Double = line.b.x - line.a.x
    let dy: Double = line.b.y - line.a.y
    
    var p, q, r: Double
    
    var isOriginClipped: Bool = false
    var isDestinationClipped: Bool = false
    
    for edge in Clipper.Edge.allCases {
        switch edge {
            case .left:
                p = -dx
                q = -(clipper.left - line.a.x)
            case .right:
                p = dx
                q = (clipper.right - line.a.x)
            case .top:
                p = -dy
                q = -(clipper.top - line.a.y)
            case .bottom:
                p = dy
                q = (clipper.bottom - line.a.y)
        }
        
        r = q / p
        
        if p == 0 && q < 0 {
            return (false, false, nil) // Don't draw line at all. (parallel line outside)
        }

        if p < 0 {
            
            if r > t1 {
              return (false, false, nil) // Don't draw line at all. (parallel line outside) // Don't draw line at all.
            } else if r > t0 {
              isOriginClipped = true
              t0 = r // Line is clipped!
            }
        } else if p > 0 {
            
            if r < t0 {
              return (false, false, nil) // Don't draw line at all.
            } else if r < t1  {
                isDestinationClipped = true
                t1 = r // Line is clipped!
            }
        }
    }
    
    return (isOriginClipped, isDestinationClipped, LineSegment(
        a: Site(
            x: line.a.x + t0 * dx,
            y: line.a.y + t0 * dy
        ),
        b: Site(
            x: line.a.x + t1 * dx,
            y: line.a.y + t1 * dy
        )
    ))
}
