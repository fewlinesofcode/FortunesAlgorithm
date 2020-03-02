import Foundation


/// Performs all the necessary calculations to represent an arrow similar to the following
public struct Arrow {
    let origin: Site
    let destination: Site
    let lHandOrigin: Site
    let rHandOrigin: Site
    
    public init(origin: Site, destination: Site) {
        self.origin = origin
        self.destination = destination
        let (l, _, r) = Self.arrowHead(a: origin, b: destination)
        self.lHandOrigin = l
        self.rHandOrigin = r
    }
    
    private static func arrowHead(
        a: Site,
        b: Site,
        length: Double = 10,
        angleDeg: Double = 15
    ) -> (left: Site, head: Site, right: Site) {
        let angle: Double = (angleDeg * .pi) / 180
        let dx = b.x - a.x
        let dy = b.y - a.y
        let theta = atan2(dy, dx)
        let rad1 = angle
        let x1 = b.x - length * cos(theta + rad1)
        let y1 = b.y - length * sin(theta + rad1)
        
        let rad2 = -angle
        let x2 = b.x - length * cos(theta + rad2)
        let y2 = b.y - length * sin(theta + rad2)
        return (
            left: Site(x: x2, y: y2),
            head: Site(x: b.x, y: b.y),
            right: Site(x: x1, y: y1)
        )
    }
}
