//
//  TesellationView.swift
//  Tesellation
//
//  Created by Oleksandr Glagoliev on 3/2/20.
//  Copyright © 2020 Oleksandr Glagoliev. All rights reserved.
//

import UIKit

class VoronoiView: UIView {
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
        var site = gesture.location(in: self).point
        site.satellite = colors[curColor % colors.count]
        curColor += 1
        sites.insert(site)
        let clippingRect = Rectangle(
            origin: Site(x: 50, y: 50),
            size: Size(width: Double(bounds.width) - 100, height: Double(bounds.height) - 100)
        )
        fs.compute(sites: sites, diagram: &diagram, clippingRect: clippingRect)
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
        diagram.cells.values.forEach { cell in
            var points: [Site] = []
            var he = cell.outerComponent
            if he == nil { return }
            while true {
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
                if he === cell.outerComponent {
                    break
                }
            }
            context.drawPolygonFromCCWPoints(points, color: (cell.site.satellite as! UIColor))
        }
    }
}

