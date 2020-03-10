import UIKit

extension UIColor {
    public static let notVisitedSite: UIColor = .clear
    public static let visitedSite: UIColor = .green
    public static let ghostParabola: UIColor = rgba(225, 235, 235)
    public static let circleEventCircle: UIColor = .orange
    public static let circleEventPoint: UIColor = .red
    public static let beachlineParabola: UIColor = .purple
    public static let ghostEdge: UIColor = .rgba(200, 200, 200)
    
    public static let vertex: UIColor = .black
    
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
    
    static let ritaPalette = [
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
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}
