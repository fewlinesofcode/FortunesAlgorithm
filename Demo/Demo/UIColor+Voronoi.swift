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
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}
