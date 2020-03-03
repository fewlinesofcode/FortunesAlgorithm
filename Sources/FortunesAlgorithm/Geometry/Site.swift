//
//  Site.swift
//  FortunesAlgorithm
//
//  Created by Oleksandr Glagoliev on 3/1/20.
//  Copyright © 2020 Oleksandr Glagoliev. All rights reserved.
//

import Foundation

/// Represent the Point in 2D Cartesian coordinate system
public struct Site {
    public var satellite: Any?
    
    public var x: Double
    public var y: Double
    
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

extension Site: Hashable {
    public static func == (lhs: Site, rhs: Site) -> Bool {
        lhs.x == rhs.x
        && lhs.y == rhs.y
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}


