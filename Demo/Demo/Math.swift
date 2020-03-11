import CoreGraphics

/// Equation of sine wave around a circle
///
///  Includes also a particular case when points will be distributed on the circle
///
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
    CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

/// Vector subtraction
/// (CGPoint is basically a 2d vector)
infix operator - : AdditionPrecedence
public func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
   CGPoint(x: rhs.x - lhs.x, y: rhs.y - lhs.y)
}

infix operator * : MultiplicationPrecedence
public func * (left: CGPoint, right: CGFloat) -> CGPoint {
    CGPoint(x: left.x * right, y: left.y * right)
}


public extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        let xDist = x - point.x
        let yDist = y - point.y
        return (xDist * xDist + yDist * yDist).squareRoot()
    }
    
    var magnitude: CGFloat {
        sqrt(x*x + y*y)
    }
}


public func radiusOfCircle(inscribedInto triangle: (pa: CGPoint, pb: CGPoint, pc: CGPoint)) -> CGFloat {
    let (pa, pb, pc) = triangle
    let a = pa.distance(to: pb)
    let b = pb.distance(to: pc)
    let c = pc.distance(to: pa)
    
    let halfP = (a + b + c) / 2
    return ((halfP - a) * (halfP - b) * (halfP - c) / halfP).squareRoot()
}


public func polygonCentroid(_ polygon: [CGPoint]) -> CGPoint {
    var centroidX: CGFloat = 0
    var centroidY: CGFloat = 0
    
    var signedArea: CGFloat = 0 // Signed area
    var x0: CGFloat = 0 // Current vertex X
    var y0: CGFloat = 0 // Current vertex Y
    var x1: CGFloat = 0 // Next vertex X
    var y1: CGFloat = 0 // Next vertex Y
    var area: CGFloat = 0 // Partial signed area

    let vertexCount = polygon.count
    let vertices = polygon
    for i in 0..<polygon.count {
        x0 = vertices[i].x
        y0 = vertices[i].y
        x1 = vertices[(i+1) % vertexCount].x
        y1 = vertices[(i+1) % vertexCount].y
        area = x0*y1 - x1*y0
        signedArea += area
        centroidX += (x0 + x1)*area
        centroidY += (y0 + y1)*area
    }
    
    signedArea *= 0.5
    centroidX /= (6.0*signedArea)
    centroidY /= (6.0*signedArea)
    
    return CGPoint(x: centroidX, y: centroidY)
}


func scaledPolygon(_ polygon: [CGPoint], scale: CGFloat) -> [CGPoint] {
    var result = [CGPoint]()
    let centroid = polygonCentroid(polygon)
    for vertex in polygon {
        result.append((centroid - vertex) * scale + centroid)
    }
    
    return result
}

func paddedPolygon(_ polygon: [CGPoint], padding: CGFloat) -> [CGPoint] {
    var result = [CGPoint]()
    let centroid = polygonCentroid(polygon)
    for vertex in polygon {
        let centroidToVertexVector = (centroid - vertex)
        let magnitude = centroidToVertexVector.magnitude
        let paddedMagnitude = magnitude + padding
        let resultVector = centroidToVertexVector * (paddedMagnitude / magnitude)
        result.append(resultVector + centroid)
    }
    return result
}


public extension CGFloat {
    var sqr: CGFloat {
        self * self
    }
    
    var positiveAngle: CGFloat {
        self < 0
            ? self + 2 * .pi
            : self
    }
}
