import Foundation

public class VoronoiDiagram {
    public private(set) var cells = [Site: Cell]()
    public private(set) var vertices = [Vertex]()
    
    public func createCell(_ arc: Arc) {
        let p = arc.point!
        let cell = Cell(site: p)
        cells[p] = cell
        arc.cell = cell
    }
    
    public func removeCell(_ cell: Cell) {
        cells.removeValue(forKey: cell.site)
    }
    
    public func createHalfEdge(_ cell: Cell) -> HalfEdge {
        let he = HalfEdge()
        if cell.outerComponent == nil {
            cell.outerComponent = he
        }
        he.incidentFace = cell
        return he
    }
    
    public func addVertex(_ v: Vertex) {
        vertices.append(v)
    }
}


/// The vertex record of a vertex v stores the coordinates of v.
/// It also stores a pointer IncidentEdge(v) to an arbitrary half‐edge that has v as its origin
public typealias Vertex = Site


/// Stores pointer to:
/// • `outerComponent` linked list (looped when diagram is built)
/// • `site` - pointer to the site
public class Cell {
    public var satellite: Any?
    public var outerComponent: HalfEdge? = nil
    
    public private(set) var site: Site
    
    public init(site: Site) {
        self.site = site
    }
}

/// The half‐edge record of a half‐edge e stores pointer to:
/// • Origin(e)
/// • Twin of e, e.twin or twin(e)
/// • The face to its left (IncidentFace(e))
/// • Next(e): next half‐edge on the boundary of IncidentFace(e)
/// • Previous(e): previous half‐edge
public class HalfEdge {
    public var satellite: Any?
    
    public var origin: Vertex?
    public var destination: Vertex?
    
    public weak var twin: HalfEdge?
    public weak var incidentFace: Cell?
    public weak var prev: HalfEdge?
    public var next: HalfEdge?
}

public extension HalfEdge {
    public func toSegment() -> LineSegment? {
        guard
            let o = origin,
            let d = destination
        else {
            return nil
        }
        return LineSegment(a: o, b: d)
    }
}
