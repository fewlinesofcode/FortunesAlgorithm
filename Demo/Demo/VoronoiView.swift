//
//  TesellationView.swift
//  Tesellation
//
//  Created by Oleksandr Glagoliev on 3/2/20.
//  Copyright © 2020 Oleksandr Glagoliev. All rights reserved.
//

import UIKit

class VoronoiView: UIView {

    var curTest = 0
    var testCases = [
        broken,
        testSites_3,
        testSites_4,
        testSites_5,
        testSites_6,
        randomSites(2, xRange: 100..<300, yRange: 50..<300),
        randomSites(3, xRange: 100..<300, yRange: 50..<300),
        randomSites(30, xRange: 100..<300, yRange: 50..<300),
        randomSites(200, xRange: 100..<300, yRange: 50..<300),
        randomSites(500, xRange: 50..<500, yRange: 50..<700),
    ]

    
    private var fs = FortuneSweep()
    var diagram = Diagram()
    var sites = Set<Site>()
    let colors = [
        UIColor.rgba(0, 227, 255),
        UIColor.rgba(95, 75, 182),
        UIColor.rgba(107, 241, 120),
        UIColor.rgba(255, 222, 0),
        UIColor.rgba(0, 34, 97),
        UIColor.rgba(179, 179, 241),
        UIColor.rgba(173, 1, 0),
        UIColor.rgba(85, 5, 39),
        UIColor.rgba(215, 178, 157),
        UIColor.rgba(213, 53, 210),
    ]
    var curColor = 0
    
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
    
    @objc func tap(_ gesture: UITapGestureRecognizer) {
        let clippingRect = Rectangle(
            origin: Site(x: 50, y: 50),
            size: Size(width: Double(bounds.width) - 100, height: Double(bounds.height) - 100)
        )
// ----------------------------------------------------
        curTest = (curTest) % testCases.count
        let sites = testCases[curTest]
        curTest += 1
        diagram = Diagram()

        fs.compute(sites: sites, diagram: &diagram, clippingRect: clippingRect)
        setNeedsDisplay()
// ----------------------------------------------------
        
        
//        var site = gesture.location(in: self).point
//        site.satellite = colors[curColor % colors.count]
//        curColor += 1
//        sites.insert(Site(x: site.x.rounded(), y: site.y.rounded()))
//
//        let axis = Double(bounds.width / 2)
//        var _x: Double
//        if site.x < axis {
//            _x = axis + (axis - site.x)
//        } else {
//            _x = axis - (site.x - axis)
//        }
//        var double = Site(x: _x.rounded(), y: site.y.rounded() + 10*eps)
//        double.satellite = site.satellite
//        sites.insert(double)
//
//        diagram = Diagram()
//        fs.compute(sites: sites, diagram: &diagram, clippingRect: clippingRect)
//        setNeedsDisplay()
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
                    color: UIColor.black.withAlphaComponent(1), lineWidth: 2.0
                )
                context.drawVertex(cell.site)
                
                he = he?.next
                finish = he === cell.outerComponent
            }
//            context.drawPolygonFromCCWPoints(points, color: (cell.site.satellite as! UIColor).withAlphaComponent(0.2))
            context.drawPolygonFromCCWPoints(points, color: UIColor.random().withAlphaComponent(0.2))
            
            let path = UIBezierPath.roundedCornersPath(points.map { $0.cgPoint }, 10)
            context.addPath(path.cgPath)
            context.drawPath(using: .stroke)
        }
    }
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
        
        // 5
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


var gridLike: [Site] {
    var res = [Site]()
    for i in 0..<Int(10) {
        for j in 0..<Int(10) {
            res.append(
                Site(x:(Double(i) + 0.5) * 40, y:(Double(j) + 0.5) * 40)
            )
        }
    }
    return res
}

var hellLike: [Site] {
    var res = [Site]()
    for i in 0..<Int(10) {
        for j in 0..<Int(10) {
            res.append(
                Site(
                    x:Double(i) * 40,
                    y:Double(j) * 40 + ((i % 2 == 0 && j % 2 == 1) ? 40 : 0)
                )
            )
        }
    }
    return res
}

var hexLike: [Site] {
    var res = [Site]()
    for i in 0..<Int(10) {
        for j in 0..<Int(10) {
            res.append(
                Site(
                    x:Double(i) * 40 + Double(j) * 20,
                    y:Double(j) * 40
                )
            )
        }
    }
    return res
}


let testSites_3 = Set<Site>(
    gridLike.map {
        Site(x: $0.x + 200, y: $0.y + 200)
    }
)

let testSites_4 = Set<Site>(
    (0...10).map {
        Site(x: Double($0) * 10, y: Double($0) * 10)
    }.map {
        Site(x: $0.x + 200, y: $0.y + 200)
    } // Diagonal
)

let testSites_5 = Set<Site>(
    hexLike.map {
        Site(x: $0.x + 200, y: $0.y + 200)
    }
)

let testSites_6 = Set<Site>(
    hellLike.map {
        Site(x: $0.x + 200, y: $0.y + 200)
    }
)

let broken = Set<Site>(
    [
//        Site(x: 508.0, y: 540.0),
//        Site(x: 481.0, y: 514.0),
//        Site(x: 370.0, y: 391.0),
//        Site(x: 344.0, y: 361.0),
//        Site(x: 324.0, y: 341.0),
//        Site(x: 314.0, y: 327.0),
//        Site(x: 297.0, y: 310.0),
//        Site(x: 279.0, y: 288.0),
        Site(x: 251.0, y: 270.0),
        Site(x: 234.0, y: 248.0),
        Site(x: 204.0, y: 202.0),
        Site(x: 166.0, y: 153.0),
    ]
)
