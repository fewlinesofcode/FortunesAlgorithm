//
//  Created by Oleksandr Glagoliev on 9/21/19.
//  Copyright © 2019 Oleksandr Glagoliev. All rights reserved.
//

import Foundation

/// Math representation of the Line (Cartesian coordinates)
/// ax + by + cz = 0
public struct Line {
    var a: Double
    var b: Double
    var c: Double
}

extension Line: CustomStringConvertible {
    public var description: String {
        return """
        \(term(val: a, param: "x"))\(term(val: b, param: "y"))\(term(val: c, param: ""))=0
        """
    }
    
    private func term(val: Double, param: String) -> String {
        if val == 0 { return "" }
        switch val.sign {
        case .plus:
            return "+\(val)\(param)"
        case .minus:
            return "\(val)\(param)"
        }
    }
}

public extension Line {
    /// Returns line defined by two points
    init(p1: Site, p2: Site) {
        a = p2.y - p1.y
        b = p1.x - p2.x
        c = p1.y * p2.x - p1.x * p1.y - p1.x * p2.y + p1.x * p1.y
    }
}
