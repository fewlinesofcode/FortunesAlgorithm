import UIKit

extension CGContext {
    public func drawCircle(
        origin: CGPoint,
        radius: CGFloat,
        strokeColor: UIColor = .black,
        strokeWidth: CGFloat = 1.0,
        fillColor: UIColor = .white,
        startAngle: CGFloat = 0,
        endAngle: CGFloat = .pi * 2) {
        
        let circle = UIBezierPath(
            arcCenter: origin,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )
        
        saveGState()
        fillColor.setFill()
        setLineWidth(strokeWidth)
        strokeColor.setStroke()
        addPath(circle.cgPath)
        drawPath(using: CGPathDrawingMode.fillStroke)
        restoreGState()
    }
    
    public func drawSegment(
        from: CGPoint,
        to: CGPoint,
        strokeColor: UIColor = .black,
        strokeWidth: CGFloat = 1.0) {
        
        saveGState()
        setLineWidth(strokeWidth)
        strokeColor.setStroke()
        move(to: from)
        addLine(to: to)
        strokePath()
        restoreGState()
    }
    
    
    public func drawPolygonFromCCWPoints(_ points: [Site], color: UIColor) {
        guard points.count > 1 else { return }
        saveGState()
        setFillColor(color.cgColor)
        move(to: points[0].cgPoint)
        for i in (0..<points.count) {
            addLine(to: points[i].cgPoint)
        }
        closePath()
        fillPath()
        restoreGState()
    }
    
    
    public func drawQuadBezier(
        from: CGPoint,
        to: CGPoint,
        cp: CGPoint,
        strokeColor: UIColor = .black,
        strokeWidth: CGFloat = 1.0
    ) {
        saveGState()
        setLineWidth(strokeWidth)
        setLineJoin(.bevel)
        setLineCap(.round)
        strokeColor.setStroke()
        move(to: from)
        addQuadCurve(to: to, control: cp)
        strokePath()
        restoreGState()
    }
    
    public func drawLine(
        from: CGPoint,
        to: CGPoint,
        color: UIColor = .lightGray,
        lineWidth: CGFloat = 1.0
    ) {
        saveGState()
        setLineWidth(lineWidth)
        color.setStroke()
        move(to: from)
        addLine(to: to)
        strokePath()
        restoreGState()
    }
    
    public func drawCross(
        _ point: Site,
        size: CGFloat,
        strokeWidth: CGFloat = 1.0,
        strokeColor: UIColor = .black
    ) {
        let p = point.cgPoint
        let tl = CGPoint(x: p.x - size, y: p.y - size)
        let bl = CGPoint(x: p.x - size, y: p.y + size)
        let br = CGPoint(x: p.x + size, y: p.y + size)
        let tr = CGPoint(x: p.x + size, y: p.y - size)
        drawLine(from: tl, to: br, color: strokeColor, lineWidth: strokeWidth)
        drawLine(from: bl, to: tr, color: strokeColor, lineWidth: strokeWidth)
    }
}
