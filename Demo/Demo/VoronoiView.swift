//
//  TesellationView.swift
//  Tesellation
//
//  Created by Oleksandr Glagoliev on 3/2/20.
//  Copyright © 2020 Oleksandr Glagoliev. All rights reserved.
//

import Foundation
import UIKit

enum Mode {
    case random
    case edgeCases
    case axis
}

class VoronoiView: UIView {
    
    // AXIS
    var axipoints = [Site]()

    var curTest = 0
    var testCases = edgeCases

    
    private var fs = FortuneSweep()
    var diagram = Diagram()
    var sites = Set<Site>()
    
    let colors = [UIColor]()
    var curColor = 0
    
    private var clippingRect: Rectangle {
        Rectangle(
            origin: Site(x: 50, y: 50),
            size: Size(width: Double(bounds.width) - 100, height: Double(bounds.height) - 100)
        )
    }
    
    // MARK: - Construction -
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tap))
        addGestureRecognizer(gesture)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    // Parametric variable
    let numberOfAxis: Int = 10
    
    @objc func tap(_ gesture: UITapGestureRecognizer) {
        
        let seedPoint = gesture.location(in: self)
        let center = Site(
            x: Double(bounds.width / 2),
            y: Double(bounds.height / 2)
        ).cgPoint
        let radius = center.distance(to: seedPoint)

        
        drawNewPortionOfAxipoints(
            generateCircularPoints(
                center: center,
                seedPoint: seedPoint,
                radius: radius,
                numberOfAxis: numberOfAxis
            )
        )
//        drawRandomSites(200)
//        drawNextEdgeCase()
    }
    
    private func generateCircularPoints(
        center: CGPoint,
        seedPoint: CGPoint,
        radius: CGFloat,
        numberOfAxis: Int
    ) -> [CGPoint] {
        var points = [CGPoint]()
        for i in 0..<numberOfAxis {
            // Dirty hack to prevent points to share coordinate
            // Otherwise it may produce glitches
            let wiggle = CGFloat(CGFloat.random(in: 0..<10) * CGFloat(eps))
            
            let theta = CGFloat(
                atan2(seedPoint.y - center.y, seedPoint.x - center.x)
            )
            let step = 2 * .pi / CGFloat(numberOfAxis)
            let curStep = step * CGFloat(i + 1)
            let a = circularWave(a: 0, c: center, r: radius, t: theta, step: curStep, n: CGFloat(numberOfAxis))
            points.append(
                CGPoint(
                    x: a.x.rounded(),
                    y: a.y.rounded() + wiggle
                )
            )
        }
        return points
    }
    
    
    private func drawNewPortionOfAxipoints(_ points: [CGPoint]) {
        axipoints.append(contentsOf: points.map { $0.point })
        redraw(Set<Site>(axipoints))
    }
    
    private func drawRandomSites(_ num: Int) {
        redraw(
            randomSites(
                num,
                xRange: 50..<Double(bounds.width) - 100,
                yRange: 50..<Double(bounds.height) - 100
            )
        )
    }
    
    private func drawNextEdgeCase() {
        curTest = (curTest) % testCases.count
        redraw(testCases[curTest])
        curTest += 1
    }
    
    private func redraw(_ sites: Set<Site>) {
        diagram = Diagram()
        fs.compute(
            sites: sites,
            diagram: &diagram,
            clippingRect: clippingRect
        )
        setNeedsDisplay()
    }
    
    
    /// Draws the receiver’s image within the passed-in rectangle.
    ///
    /// - Parameter rect: The portion of the view’s bounds that needs to be updated
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }

        context.clear(rect)
        context.setFillColor(UIColor.white.cgColor)
        context.fill(rect)
    
        // Draw diagram cells
        axipoints.forEach { pt in
            context.drawVertex(pt)
        }
        
        // Draw diagram cells
        diagram.cells.values.forEach { cell in
            var points: [Site] = []
            var he = cell.outerComponent

            var finish = false
            while !finish {

                if he!.toSegment()!.length() < 1.0 {
                    he = he?.next
                    finish = he === cell.outerComponent
                    continue
                }

                let o = he!.origin!
                let d = he!.destination!

                points.append(o)

                context.drawLine(
                    from: o.cgPoint,
                    to: d.cgPoint,
                    color: UIColor.black.withAlphaComponent(0.05), lineWidth: 2.0
                )

                // Site
                context.drawVertex(cell.site)

                he = he?.next
                finish = he === cell.outerComponent
            }
//            context.drawPolygonFromCCWPoints(points, color: (cell.site.satellite as! UIColor).withAlphaComponent(0.2))
//            context.drawPolygonFromCCWPoints(points, color: UIColor.random().withAlphaComponent(0.2))

            // Centroid
//            let centroid = polygonCentroid(points)
//            context.drawVertex(centroid)

            let path = UIBezierPath.roundedCornersPath(points.map { $0.cgPoint }, 10)
            context.addPath(path.cgPath)


            let path2 = UIBezierPath.roundedCornersPath(scaledPolygon(points, scale: 0.85).map { $0.cgPoint }, 100)
            context.addPath(path2.cgPath)

            context.drawPath(using: .stroke)
        }
    }
}

func scaledPolygon(_ polygon: [Site], scale: Double) -> [Site] {
    var result = [Site]()
    let centroidVector = polygonCentroid(polygon).vector
    for vertex in polygon {
        let vertexVector = vertex.vector
        let v = (centroidVector - vertexVector)
//        let m = v.magnitude
//        let decM = v.magnitude - 5.0
//        let resultVector = v * (decM / m) + centroidVector
        let resultVector = v * scale + centroidVector
        result.append(resultVector.point)
    }
    
    return result
}

func polygonCentroid(_ polygon: [Site]) -> Site {
    var centroidX: Double = 0
    var centroidY: Double = 0
    
    var signedArea: Double = 0 // Signed area
    var x0: Double = 0 // Current vertex X
    var y0: Double = 0 // Current vertex Y
    var x1: Double = 0 // Next vertex X
    var y1: Double = 0 // Next vertex Y
    var area: Double = 0 // Partial signed area

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
    
    return Site(x: centroidX, y: centroidY)
}


private extension CGFloat {
    var sqr: CGFloat {
        self * self
    }
    
    var positiveAngle: CGFloat {
        self < 0
            ? self + 2 * .pi
            : self
    }
}

func rad2deg(_ number: CGFloat) -> CGFloat {
    return number * 180 / .pi
}

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        let xDist = x - point.x
        let yDist = y - point.y
        return (xDist * xDist + yDist * yDist).squareRoot()
    }
}

extension UIBezierPath {
    private static func addCorner(_ path: UIBezierPath, p1: CGPoint, p: CGPoint, p2: CGPoint, radius: CGFloat, isStart: Bool = false) {
        let a = p.distance(to: p1)
        let b = p.distance(to: p2)
        let c = p1.distance(to: p2)
        let halfP = (a + b + c) / 2
        let r = ((halfP - a)*(halfP - b)*(halfP - c)/halfP).squareRoot()
        var radius = min(r, radius)
        
        
        let angle = CGFloat(atan2(p.y - p1.y, p.x - p1.x) - atan2(p.y - p2.y, p.x - p2.x)).positiveAngle
        
        var segment = radius / abs(tan(angle / 2))
        let p_c1 = segment
        let p_c2 = segment
        
        
        let p_p1 = p.distance(to: p1)
        let p_p2 = p.distance(to: p2)
        
        segment = min(segment, min(p_p1, p_p2))
        radius = segment * abs(tan(angle / 2))
        
        let p_o = sqrt(radius.sqr + segment.sqr)

        // 6
        let c1 = CGPoint(
            x: (p.x - (p.x - p1.x) * p_c1 / p_p1),
            y: (p.y - (p.y - p1.y) * p_c1 / p_p1)
        )
        

        //  7
        let c2 = CGPoint(
            x: (p.x - (p.x - p2.x) * p_c2 / p_p2),
            y: (p.y - (p.y - p2.y) * p_c2 / p_p2)
        )
        

        // 8
        let dx = p.x * 2 - c1.x - c2.x
        let dy = p.y * 2 - c1.y - c2.y

        let p_c = (dx.sqr + dy.sqr).squareRoot()

        let o = CGPoint(
            x: p.x - dx * p_o / p_c,
            y: p.y - dy * p_o / p_c
        )

        // 9
        let start_angle = (atan2((c1.y - o.y), (c1.x - o.x))).positiveAngle
        let end_angle = (atan2((c2.y - o.y), (c2.x - o.x))).positiveAngle


        if isStart {
            path.move(to: c1)
        } else {
            path.addLine(to: c1)
        }
        
        path.addArc(withCenter: o, radius: radius, startAngle: start_angle, endAngle: end_angle, clockwise: angle < .pi)
    }
    
    public static func roundedCornersPath(_ pts: [CGPoint], _ r: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        for i in 1...pts.count {
            let prev = pts[i-1]
            let curr = pts[i % pts.count]
            let next = pts[(i + 1) % pts.count]
            addCorner(path, p1: prev, p: curr, p2: next, radius: r, isStart: i == 1)
        }
        path.close()
        return path
    }
}

// TODO: This code block should be removed in the final implementation
//       It is here for testing convenience
func randomSites(_ num: Int, xRange: Range<Double>, yRange: Range<Double>) -> Set<Site> {
    let set = Set<Site>(
        (0..<num).map { _ in
            Site(
                x: Double.random(in: xRange).rounded(),
                y: Double.random(in: yRange).rounded()
            )
        }
    )
//    set.sorted(by: { $0.y < $1.y }).forEach {
//        print("Point\($0)")
//    }
    return set
}
