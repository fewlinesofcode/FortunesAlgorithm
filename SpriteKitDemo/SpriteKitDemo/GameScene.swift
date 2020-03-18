//
//  GameScene.swift
//  SpriteKitDemo
//
//  Created by Oleksandr Glagoliev on 3/12/20.
//  Copyright © 2020 Oleksandr Glagoliev. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var fs = FortuneSweep()
    var diagram = Diagram()
    var points = [SKShapeNode]()
    
    var shouldRedraw = true
    var elapsedTime: TimeInterval = 0
    var shape: SKShapeNode = SKShapeNode()
    
    private var clippingRect: Rectangle {
        Rectangle(
            origin: Site(x: 50, y: 50),
            size: Size(width: Double(frame.width) - 100, height: Double(frame.height) - 100)
        )
    }
        
    private func redraw(_ sites: Set<Site>) {
//        removeAllChildren()
        
        diagram.clear()
        fs.compute(
            sites: sites,
            diagram: &diagram,
            clippingRect: clippingRect
        )
        
        
        let totalPath = UIBezierPath()
        
        diagram.cells.forEach { cell in
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
                
                
                he = he?.next
                finish = he === cell.outerComponent
            }
            
            let hullVertices = points.map { $0.cgPoint }
            
            for i in 0..<1 {
                let paddedHull = paddedPolygon(hullVertices, padding: CGFloat(-i) * 10)
                if let path = UIBezierPath.roundedCornersPath(paddedHull, 10) {
                    totalPath.append(path)
                }
            }
        }
        
        shape.path = totalPath.cgPath
        shape.strokeColor = UIColor.black
//        shape.lineWidth = 0
        shape.fillColor = .clear
    }
    
    override func didMove(to view: SKView) {
        addChild(shape)
        
        let offset: Double = 50
        let lbx = offset
        let lby = offset
        let ubx = Double(view.bounds.width) - 2 * offset
        let uby = Double(view.bounds.height) - 2 * offset
        let randomPoints = randomSites(50, xRange: lbx..<ubx, yRange: lby..<uby)
        let r: CGFloat = 10
        points = randomPoints.map {
            let point = SKShapeNode(circleOfRadius: r)
            point.position = $0.cgPoint
            point.fillColor = .red
            
            let body = SKPhysicsBody(circleOfRadius: r)
            body.affectedByGravity = false
            body.linearDamping = 0
            body.mass = 0.0
            
            point.physicsBody = body
            point.isHidden = false
            
            addChild(point)
            return point
        }
        
        redraw(Set<Site>(points.map { $0.position.point }))
    }
    
    func getRandomPoint(withinRect rect: CGRect) -> CGPoint{
        
        let x = CGFloat(arc4random()).truncatingRemainder(dividingBy: rect.size.width)
        let y = CGFloat(arc4random()).truncatingRemainder(dividingBy: rect.size.height)
        
        return CGPoint(x: x, y: y)
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
        return set
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        shouldRedraw = true
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        let spriteAtPoint = atPoint(pos)
        if spriteAtPoint != shape {
            atPoint(pos).position = pos
        }
        redraw(Set<Site>(points.map { $0.position.point }))
    }
    
    func touchUp(atPoint pos : CGPoint) {
        points.forEach {
            $0.physicsBody!.affectedByGravity = true
        }
        
//        redraw(Set<Site>(sites))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
}

extension CGPoint {
    public var point: Site {
        Site(x: Double(x), y: Double(y))
    }
}

extension Site {
    public var cgPoint: CGPoint {
        CGPoint(x: x, y: y)
    }
}

extension UIColor {
    public static func rgba(_ r: Int, _ g: Int, _ b: Int, _ a: Int = 1) -> UIColor {
        return UIColor(
            red: CGFloat(r) / CGFloat(235.0),
            green: CGFloat(g) / CGFloat(235.0),
            blue: CGFloat(b) / CGFloat(235.0),
            alpha: CGFloat(a)
        )
    }
    
    static func random() -> UIColor {
        return UIColor(red:   .random(),
                       green: .random(),
                       blue:  .random(),
                       alpha: 1.0)
    }
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}
