//
//  Created by Oleksandr Glagoliev on 17/06/2019.
//  Copyright © 2019 Oleksandr Glagoliev. All rights reserved.
//

import Foundation

// MARK: - Circle
public struct Circle {
    public let center: Site
    public let radius: Double
    
    /// Defines circle by three points
    /// See: https://www.xarg.org/2018/02/create-a-circle-out-of-three-points/
    public init?(p1: Site, p2: Site, p3: Site) {
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
        
        center = Site(x: x, y: y)
        radius = hypot(x - x1, y - y1)
    }
    
    
    /// Constructor. Defines a Circle by it's center and radius
    /// - Parameters:
    ///   - center: Circle origin (center)
    ///   - radius: Circle radius
    public init(center: Site, radius: Double) {
        self.center = center
        self.radius = radius
    }
}

extension Circle {
    // Returns a point with maximum *Y* coordinate
    public var bottomPoint: Site {
        Site(
            x: center.x,
            y: center.y + radius
        )
    }
}

extension Circle: CustomStringConvertible {
    public var description: String {
        return "Circle: \(radius)^2=(x-\(center.x))^2+(y-\(center.y))^2"
    }
}
