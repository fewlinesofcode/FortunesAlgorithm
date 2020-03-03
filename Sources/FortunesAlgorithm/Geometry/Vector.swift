//
//  Vector2D.swift
//
//  Created by fewlinesofcode.com on 2/6/19.
//  Copyright © 2019 fewlinesofcode.com All rights reserved.
//

import Foundation


public struct Vector2D {
    var dx = 0.0, dy = 0.0
    
    public init(dx: Double, dy: Double) {
        self.dx = dx
        self.dy = dy
    }
}


extension Vector2D {
    // Vector addition
    public static func + (left: Vector2D, right: Vector2D) -> Vector2D {
        return Vector2D(dx: left.dx + right.dx, dy: left.dy + right.dy)
    }
    
    // Vector subtraction
    public static func - (left: Vector2D, right: Vector2D) -> Vector2D {
        return Vector2D(dx: right.dx - left.dx, dy: right.dy - left.dy)
    }
}


infix operator * : MultiplicationPrecedence


public extension Vector2D {
    // Scalar-vector multiplication
    static func * (left: Double, right: Vector2D) -> Vector2D {
        return Vector2D(dx: right.dx * left, dy: right.dy * left)
    }
    
    static func * (left: Vector2D, right: Double) -> Vector2D {
        return Vector2D(dx: left.dx * right, dy: left.dy * right)
    }
}
