// MIT License
//
// Copyright (c) 2020 Oleksandr Glagoliev
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.


import Foundation

public class Diagram {
    public private(set) var cells = [Cell]()
    public private(set) var vertices = [Vertex]()
    
    public init() { }
    
    func createCell(_ arc: Arc) {
        let p = arc.point!
        let cell = Cell(site: p)
        cells.append(cell)
        arc.cell = cell
    }
    
    func createHalfEdge(_ cell: Cell) -> HalfEdge {
        let he = HalfEdge()
        if cell.outerComponent == nil {
            cell.outerComponent = he
        }
        he.incidentFace = cell
        return he
    }
    
    public func clear() {
        cells.removeAll()
        vertices.removeAll()
    }
}


/// The vertex record of a vertex v stores the coordinates of v.
/// It also stores a pointer IncidentEdge(v) to an arbitrary half‐edge that has v as its origin
public typealias Vertex = Site
public typealias Point = Site


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
    
    deinit {
        outerComponent?.next = nil
        outerComponent?.prev = nil
    }
}

public extension Cell {
    
    /// Returns hell vertices of the cell
    func hullVerticesCCW() -> [Vertex] {
        var vertices: [Vertex] = []
        guard var he = outerComponent else {
            return []
        }
        
        var finish = false
        while !finish {
            vertices.append(he.origin!)
            he = he.next!
            finish = he === outerComponent
        }
        
        return vertices
    }
    
    
    /// Returns all the neighbours of specific cell
    func neighbours() -> [Cell] {
        var neighbours = [Cell]()
        guard var he = outerComponent else {
            return []
        }
        
        var finish = false
        while !finish {
            if let neighbour = he.twin?.incidentFace {
                neighbours.append(neighbour)
            }
            he = he.next!
            finish = he === outerComponent
        }
        return neighbours
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

