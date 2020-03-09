import CoreGraphics

/// Equation of sine wave around a circle

/// x = (R + a · sin(n·θ)) · cos(θ) + xc
/// y = (R + a · sin(n·θ)) · sin(θ) + yc
///
/// - Parameters:
///   - a: Sinusoid amplitude
///   - c: Circle's origin
///   - r: Circle's radius
///   - t: Variable parameter
///   - shift: Phase shift
///   - step: Density step
///   - n: Number of periods
/// - Returns: Result of the equation
public func circularWave(a: CGFloat, c: CGPoint, r: CGFloat, t: CGFloat, shift: CGFloat = 0, step: CGFloat, n: CGFloat = 10) -> CGPoint {
    let x = (r + a * sin(n * (t + step) + shift)) * cos((t + step)) + c.x
    let y = (r + a * sin(n * (t + step) + shift)) * sin((t + step)) + c.y
    return CGPoint(x: x, y: y)
}


/// Convenience method for vector addition
/// (CGPoint is basically a 2d vector)
infix operator + : AdditionPrecedence
public func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

