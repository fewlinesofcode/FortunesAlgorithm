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
    
    
    @objc func tap(_ gesture: UITapGestureRecognizer) {
        
//        let seedPoint = gesture.location(in: self)
//        drawNewPortionOfAxipoints(
//            generateCircularPoints(
//                center: Site(
//                    x: Double(bounds.width / 2),
//                    y: Double(bounds.height / 2)
//                ).cgPoint,
//                seedPoint: seedPoint,
//                radius: center.distance(to: seedPoint),
//                numberOfAxis: 1
//            )
//        )
//        if axipoints.count > 4 {
//            axipoints = Array<Site>(axipoints.dropFirst(axipoints.count - 5))
//        }

        
        drawRandomSites(10)
        
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
            let wiggle = CGFloat(CGFloat.random(in: 0..<10) * 0.2)
            
            let theta = CGFloat(
                atan2(seedPoint.y - center.y, seedPoint.x - center.x)
            )
            let step = 2 * .pi / CGFloat(numberOfAxis)
            let curStep = step * CGFloat(i + 1)
            let a = circularWave(a: 0, c: center, r: radius, t: theta, step: curStep, n: CGFloat(numberOfAxis))
            points.append(
                CGPoint(
                    x: a.x.rounded() - wiggle,
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
                xRange: 150..<Double(bounds.width) - 300,
                yRange: 150..<Double(bounds.height) - 300
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
//        axipoints.forEach { pt in
//            context.drawVertex(pt)
//        }
        
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
                points.append(o)
                
                
//                let d = he!.destination!
//                context.drawLine(
//                    from: o.cgPoint,
//                    to: d.cgPoint,
//                    color: UIColor.black.withAlphaComponent(0.05), lineWidth: 2.0
//                )

                // Site
//                context.drawVertex(cell.site)

                he = he?.next
                finish = he === cell.outerComponent
            }
            
//            context.drawPolygonFromCCWPoints(points, color: UIColor.random().withAlphaComponent(0.2))

            let hullVertices = points.map { $0.cgPoint }
            
//            context.addPath(
//                UIBezierPath.roundedCornersPath(hullVertices, 10).cgPath
//            )
//
//            let scaledHull = scaledPolygon(hullVertices, scale: 0.9)
//            context.addPath(
//                UIBezierPath.roundedCornersPath(scaledHull, 10).cgPath
//            )
//
//            let paddedHull = paddedPolygon(hullVertices, padding: -15.0)
//            context.addPath(
//                UIBezierPath.roundedCornersPath(paddedHull, 10).cgPath
//            )
            
            for i in 0..<40 {
                let paddedHull = paddedPolygon(hullVertices, padding: CGFloat(-i) * 8)
                context.addPath(
                    //CGFloat(i) * 2
                    UIBezierPath.roundedCornersPath(paddedHull, 0).cgPath
                )
            }
            
            context.drawPath(using: .stroke)
        }
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
