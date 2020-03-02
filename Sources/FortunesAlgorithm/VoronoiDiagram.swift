import Foundation

public class VoronoiDiagram {
    private(set) var cells = [Site: Cell]()
    private(set) var vertices = [Vertex]()
    
    func createCell(_ arc: Arc) {
        let p = arc.point!
        let cell = Cell(site: p)
        cells[p] = cell
        arc.cell = cell
    }
    
    func removeCell(_ cell: Cell) {
        cells.removeValue(forKey: cell.site)
    }
    
    func createHalfEdge(_ cell: Cell) -> HalfEdge {
        let he = HalfEdge()
        if cell.outerComponent == nil {
            cell.outerComponent = he
        }
        he.incidentFace = cell
        return he
    }
    
    func addVertex(_ v: Vertex) {
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
    var satellite: Any?
    var outerComponent: HalfEdge? = nil
    
    private(set) var site: Site
    
    init(site: Site) {
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
    var satellite: Any?
    
    var origin: Vertex?
    var destination: Vertex?
    
    weak var twin: HalfEdge?
    weak var incidentFace: Cell?
    weak var prev: HalfEdge?
    var next: HalfEdge?
}

public extension HalfEdge {
    func toSegment() -> LineSegment? {
        guard
            let o = origin,
            let d = destination
        else {
            return nil
        }
        return LineSegment(a: o, b: d)
    }
}
