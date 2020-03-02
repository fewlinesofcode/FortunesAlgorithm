//
//  Vector2D.swift
//
//  Created by fewlinesofcode.com on 2/6/19.
//  Copyright © 2019 fewlinesofcode.com All rights reserved.
//

import Foundation

public struct Vector2D {
    var dx = 0.0, dy = 0.0
    
    public static let zero = Vector2D(dx: 0, dy: 0)
    
    public init(dx: Double, dy: Double) {
        self.dx = dx
        self.dy = dy
    }
}

extension Vector2D: CustomStringConvertible {
    public var description: String {
        return "(x: \(dx), y: \(dy))"
    }
}

extension Vector2D: AdditiveArithmetic {
    // Vector addition
    public static func + (left: Vector2D, right: Vector2D) -> Vector2D {
        return Vector2D(dx: left.dx + right.dx, dy: left.dy + right.dy)
    }
    
    // Vector subtraction
    public static func - (left: Vector2D, right: Vector2D) -> Vector2D {
        return Vector2D(dx: right.dx - left.dx, dy: right.dy - left.dy)
    }
    
    // Vector addition assignment
    public static func += (left: inout Vector2D, right: Vector2D) {
        left = left + right
    }
    
    // Vector subtraction assignment
    public static func -= (left: inout Vector2D, right: Vector2D) {
        left = left - right
    }
    
    // Vector negation
    public static prefix func - (vector: Vector2D) -> Vector2D {
        return Vector2D(dx: -vector.dx, dy: -vector.dy)
    }
}

infix operator * : MultiplicationPrecedence
infix operator / : MultiplicationPrecedence
infix operator • : MultiplicationPrecedence

public extension Vector2D {
    // Scalar-vector multiplication
    static func * (left: Double, right: Vector2D) -> Vector2D {
        return Vector2D(dx: right.dx * left, dy: right.dy * left)
    }
    
    static func * (left: Vector2D, right: Double) -> Vector2D {
        return Vector2D(dx: left.dx * right, dy: left.dy * right)
    }
    
    // Vector-scalar division
    static func / (left: Vector2D, right: Double) -> Vector2D {
        guard right != 0 else { fatalError("Division by zero") }
        return Vector2D(dx: left.dx / right, dy: left.dy / right)
    }
    
    // Vector-scalar division assignment
    static func /= (left: inout Vector2D, right: Double) -> Vector2D {
        guard right != 0 else { fatalError("Division by zero") }
        return Vector2D(dx: left.dx / right, dy: left.dy / right)
    }
    
    // Scalar-vector multiplication assignment
    static func *= (left: inout Vector2D, right: Double) {
        left = left * right
    }
}

public extension Vector2D {
    // Vector magnitude (length)
    var magnitude: Double {
        return sqrt(dx*dx + dy*dy)
    }
    
    // Distance between two vectors
    func distance(to vector: Vector2D) -> Double {
        return (self - vector).magnitude
    }
    
    // Vector normalization
    var normalized: Vector2D {
        return Vector2D(dx: dx / magnitude, dy: dy / magnitude)
    }
    
    // Dot product of two vectors
    static func • (left: Vector2D, right: Vector2D) -> Double {
        return left.dx * right.dx + left.dy * right.dy
    }
    
    // Angle between two vectors
    // θ = acos(AB)
    func angle(to vector: Vector2D) -> Double {
        return acos(self.normalized • vector.normalized)
    }
}

extension Vector2D: Equatable {
    public static func == (left: Vector2D, right: Vector2D) -> Bool {
        return (left.dx == right.dx) && (left.dy == right.dy)
    }
}
