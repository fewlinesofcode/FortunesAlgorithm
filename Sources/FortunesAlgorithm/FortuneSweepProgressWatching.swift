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

public protocol FortuneSweepProgressWatching: class {
    
    /// Depicts current step of an algorithm
    var step: Int { get set }
    
    /// Called when algorithm is ready to work
    /// - Parameter sites: Same as Fortunes Algorithm input
    /// - Parameter clipper: Clipping rectangle
    func prepare(sites: Set<Site>, clipper: Rectangle)
    
    
    /// Called when sweepline changes position
    /// - Parameter y: New sweepline Y position
    func updateSweepline(y: Double)
    
    /// Called when Site Event occured
    /// - Parameter site: Visited site
    func siteEvent(site: Site)
    
    /// Called when Circle Event occured
    /// - Parameter site: Visited site
    func circleEvent(point: Point)
    
    
    /// Called when bounding rectangle is changed
    /// - Parameter rectangle: New Bounding rectangle
    func updateContainer(rectangle: Rectangle)
    
    
    /// Called when new breakpoint occured
    /// - Parameter point: Breakpoint
    func updateCurentBreakpoint(point: Point?)
    
    
    /// Called when beachline is updated
    /// - Parameter arcs: Arcs, currently present in the Beachline
    func updateBeachline(arcs: [BeachlineSegment])
    
    
    /// Called when upcoming circle event is added to the Event Queue
    /// - Parameter circle: Circle event circle
    func addUpcomingCircleEvent(circle: Circle)
    
    
    /// Called when Circle event is removed from Event Queue
    /// - Parameter circle: Circle event circle
    func removeFalseAlarmCircleEvent(circle: Circle)
    
    
    /// Called when new Vertex is created
    /// - Parameter vertex: Vertex
    func createVertex(vertex: Vertex)
    
    /// Called when new Cell is added to the diagram
    /// - Parameter cell: Cell
    func createCell(cell: Cell)
}
