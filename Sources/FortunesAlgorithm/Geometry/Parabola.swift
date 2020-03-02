//
//  Created by Oleksandr Glagoliev on 17/06/2019.
//  Copyright © 2019 Oleksandr Glagoliev. All rights reserved.
//

import Foundation

public struct Parabola {
    public var focus: Site
    public var directrixY: Double
    
    
    /// Constructor that defines parabola by the focus and the directrix that is **Parallel** to *X-axis*!
    /// - Parameters:
    ///   - focus: Parabola focus
    ///   - directrixY: Directix *Y*
    public init(focus: Site, directrixY: Double) {
        self.focus = focus
        self.directrixY = directrixY
    }
    
    /// Resolves parabola equation against given *X*
    /// - Parameter x: given x
    public func resolve(x: Double) -> Double {
        let (a, b, c) = standardForm
        let y = a * (x * x) + b * x + c
        return y
    }
    
    /// Converts parabola to standart form (ax^2 + by * c)
    public var standardForm: (a: Double, b: Double, c: Double) {
        let vx = (focus.y + directrixY) / 2 // X coord of parabola vertex
        let vy = (focus.y - directrixY) / 2 // Y coord of parabola vertex
        let a = 1 / (4 * vy)
        let b = (-1 * focus.x) / (2 * vy)
        let c = (focus.x * focus.x) / (4 * vy) + vx
        return (a: a, b: b, c: c)
    }
    
    
    /// Quadrativ Bezier representation of the Parabola clipped by *X*
    /// - Parameters:
    ///   - minX: Min *X* clippling point
    ///   - maxX: Max *X* clippling point
    public func toQuadBezier(minX: Double, maxX: Double) -> (start: Site, cp: Site, end: Site) {
        let (minX, maxX) = (min(minX, maxX), max(minX, maxX))
        
        let (a, b, _) = standardForm
        let start = Site(x: minX, y: resolve(x: minX))
        let end = Site(x: maxX, y: resolve(x: maxX))
        let cx = (minX + maxX) / 2
        let cy = (maxX - minX) / 2 * (2 * a * minX + b) + resolve(x: minX)
        let cp = Site(x: cx, y: cy)
        return (start: start, cp: cp, end: end)
    }

    
    
    /// *X* coordinate of the intersection with other Parabola (if present)
    /// - Parameter parabola: other parabola
    public func intersectionX(_ parabola: Parabola) -> Double? {
        let focusLeft = focus
        let focusRight = parabola.focus
        let directrix = directrixY
        
        /// Handle the degenerate case when two parabolas have the same Y
        /// If two parabolas have the same Y, then the intersection lies exactly at the middle between them.
        if focusLeft.y == focusRight.y {
            return (focusLeft.x + focusRight.x) / 2
        }
        
        /// Handle the degenerate case where one or both of the sites have the same Y value.
        /// In this case the focus of one or both sites and the directrix would be equal.
        if focusLeft.y == directrix {
            return focusLeft.x
        } else if focusRight.y == directrix {
            return focusRight.x
        }
        
        /// Determine the a, b and c coefficients for the two parabolas
        let (a1, b1, c1) = standardForm
        let (a2, b2, c2) = parabola.standardForm
        
        /// Calculate the roots of the coefficients difference.
        let a = a1 - a2
        let b = b1 - b2
        let c = c1 - c2
        
        let discriminant = b * b - 4 * a * c
        let x1 = (-b + discriminant.squareRoot()) / (2 * a)
        let x2 = (-b - discriminant.squareRoot()) / (2 * a)
        
        /// X of the intersection is one of those roots.
        let x: Double = (focusLeft.y < focusRight.y)
            ? min(x1, x2)
            : max(x1, x2)
        
        if x.isNaN {
            return nil
        }
        return x
    }
}





