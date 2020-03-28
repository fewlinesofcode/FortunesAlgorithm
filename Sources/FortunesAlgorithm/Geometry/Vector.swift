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
    
    // Vector magnitude (length)
    var magnitude: Double {
        return sqrt(dx*dx + dy*dy)
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
