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

public class FortuneSweep {
    /// Service Data Structures
    private var eventQueue: PriorityQueue<Event>!
    private var beachline: Beachline!
    private var sweepLineY: Double = 0 {
        didSet {
            watcher?.updateSweepline(y: sweepLineY)
        }
    }
    private var firstSiteY: Double?
    
    private var container: Rectangle! {
        didSet {
            watcher?.updateContainer(rectangle: container)
        }
    }
    private var clipper: Rectangle!
    
    /// Debug Data structures
    private var logger: FortuneSweepLogging?
    private var watcher: FortuneSweepProgressWatching?
    private var currentStep: Int = 0 {
        didSet {
            watcher?.step = currentStep
        }
    }
    /// Result Data Structure
    private(set) var diagram: Diagram!
    
    
    /// Initialises new FortuneSweep instance
    /// NB: `logger` and especially `watcher` will affect performance!
    /// Use them only for debug purposes!
    ///
    /// - Parameters:
    ///   - logger: Optional. Calls `log` function when importand events happen
    ///   - watcher: Optional. **Affects performance!** Tracks diagram building process. May be used for visualisation as it includes useful scaffolding.
    public init(
        logger: FortuneSweepLogging? = nil,
        intermediate: FortuneSweepProgressWatching? = nil
    ) {
        self.logger = logger
        self.watcher = intermediate
    }
    
    public func compute(
        sites: Set<Site>,
        diagram: inout Diagram,
        clippingRect: Rectangle,
        maxStepsCount: Int = -1
    ) -> Bool {
        self.diagram = diagram
        self.clipper = clippingRect
        let filteredSites = sites.filter { clipper.contains($0) }
            
        let events = filteredSites.map { Event(point: $0) }
        
        /// Intermediate state
        watcher?.prepare(sites: filteredSites, clipper: clippingRect)
        
        /// Diagram is a whole plane. Do nothing
        if events.isEmpty {
            logger?.log("Computation done. No sites inside defined area!", level: .info)
            return true
        }
        
        currentStep = 0
        sweepLineY = 0
        firstSiteY = nil
        beachline = Beachline()
        
        eventQueue = PriorityQueue(
            ascending: true,
            startingValues: events
        )
        
        logger?.log("\n\nComputation started!", level: .info)
        
        while !eventQueue.isEmpty && currentStep != maxStepsCount {
            step()
        }
        if eventQueue.isEmpty {
            terminate()
            return true
        }
        return false
    }
    
    
    /// Runs one step of an algorithm
    func debug_step() -> Bool {
        step()
        if eventQueue.isEmpty {
            terminate()
            return true
        }
        return false
    }
    
    /// Performs one step of the algorithm
    /// 1. Pop an event from the event queue
    /// 2. Check the event type and process the event appropriately
    private func step() {
        currentStep += 1
        logger?.log("\nStep: \(currentStep)", level: .info)
        
        if let event = eventQueue.pop() {
            switch event.kind {
                case .site:
                    processSiteEvent(event)
                case .circle:
                    processCircleEvent(event)
            }
        }
    }
    
    
    /// Processes **Site event** and performs all the necessary actions
    /// - Parameter event: **Site Event** to process
    private func processSiteEvent(_ event: Event) {
        logger?.log("Site Event: \(event.point)", level: .info)
        watcher?.siteEvent(site: event.point)
        
        /// #Step 1:
        /// Update **Sweepline** position
        sweepLineY = event.point.y
        beachline.updateSweeplineY(sweepLineY)
        
        /// #Step 2:
        /// Each **Site Event** makes new arc(s) to appear in the **Beachline**
        /// There are few possible cases:
        
        /// Case 1: (Always present once)
        /// Beachline is empty. Create beachline root Arc and return
        if beachline.isEmpty {
            logger?.log("Site Event first occurence. Root arc inserted for Site: \(event.point)", level: .info)
            let root = beachline.insertRootArc(point: event.point)
            firstSiteY = event.point.y
            
            let padding: Double = 20 // Arbitrary padding to make sure that container contains clipping rect
            container = .rect(from: clipper, with: padding)
            
            /// Create new **Cell** record in **Voronoi Diagram**
            container.expandToContainPoint(event.point)
            diagram.createCell(root)
            watcher?.createCell(cell: root.cell)
            return
        }
        
        /// Case 2: Degenerate (less likely)
        /// There is only one site in the **Beachline**. Exisiting site shares Y coordinate with new site
        /// In this case two parabolas are degenerating into Rays origining at their event point and pointing up.
        /// They have no intersection point but we know two things about the future of this case:
        ///     - The *x* coordinate of the intersection point point will be exactly in the middle
        ///     - *y* coordinate will lay somewhere far above the points.
        /// We replace *y* with an arbitrary value big enough to cover our case. (`yVal`)
        if firstSiteY == sweepLineY {
            logger?.log("Site Event degenerate case (Existing Sites share Y coodinate (\(sweepLineY)) with new Site) for Site: \(event.point)", level: .warning)
            
            container.expandToContainPoint(event.point)
            let yVal: Double = -1000000//.leastNormalMagnitude
            let arc = beachline.handleSpecialArcInsertionCase(event.point)

            /// 1. Create new **Cell** record in **Voronoi Diagram**
            diagram.createCell(arc)
            watcher?.createCell(cell: arc.cell)

            /// 2. Create proper *HalfEdge* records. Arc with the same *y* can only appear
            /// to the right of existing one as in case of *y* coordinate is shared they are sorted by *x*
            let prev = arc.prev!
            let p = Site(x: (prev.point!.x + arc.point!.x) / 2, y: yVal)
            prev.rightHalfEdge = diagram.createHalfEdge(prev.cell!)
            prev.rightHalfEdge?.destination = p
            arc.leftHalfEdge = diagram.createHalfEdge(arc.cell!)
            arc.leftHalfEdge?.origin = p
            makeTwins(prev.rightHalfEdge, arc.leftHalfEdge)
            
            /// There is no sense to check for circle event when we encounter degenerate case because all the sites are colinear
            return
        }
        
        /// Case 3. (Most likely)
        /// At this point we have at least one arc in the **Beachline**.
        /// The **Beachline** is X-monotonous, that's why we can find corresponding arc.
        /// This is the only arc which contains `event.point.x`
        /// This arc will be splitted into three arcs. New arc and it's two successors (the arc we found is *left*)
        /// **Special case**
        /// There is one special (less likely) case when the Site's *x* equals `breakPoint.x` (so the new arc point lays exactly under
        /// two arc intersection). This case requires special code
        let (newArc, isSpecialCase) = beachline.insertArcForPoint(event.point)
        
        /// Create new **Cell** record in **Voronoi Diagram**
        container.expandToContainPoint(event.point)
        diagram.createCell(newArc)
        watcher?.createCell(cell: newArc.cell)
        
        /// Notify `intermediate` if needed
        if let intermediate = self.watcher {
            let parabola = Parabola(focus: newArc.prev!.point!, directrixY: sweepLineY)
            let breakPoint = Point(
                x: event.point.x,
                y: parabola.resolve(x: event.point.x)
            )
            intermediate.updateCurentBreakpoint(point: breakPoint)
        }
        
        /// #Step 3:
        /// If the arc we broke has circle event, than this event is false-alarm and has to be removed
        removeCircleEvent(newArc.prev)
        
        /// #Step 4:
        /// Check the triple of consecutive arcs where the *new arc* is the *left* arc to see if the breakpoints converge.
        /// If so, insert the **Circle Event** into **Priority Queue** and add pointers between the **Arc** and **Priority Queue** record
        /// Do the same for the triple where the *new* arc is the *right* arc
        createCircleEvent(newArc.prev!)
        createCircleEvent(newArc.next!)
        
        /// #Step 5:
        /// Create new **Half Edge** records in the **Voronoi Diagram** structure
        let next = newArc.next!
        let prev = newArc.prev!
        
        /// **Special Case**
        /// Here we handle the special case mentioned in **Step 2** **Case 3**
        /// In this case we create three pairs of **HalfEdges** and their intersection point
        /// The intersection point will serve as a **Vertex** in the diagram
        if isSpecialCase {
            /// Less likely Special Case handling
            /// Basically we're connecting **HalfEdge** pairs to create a connection like follows:
            ///     |
            ///     o
            ///    / \
            /// We also maintain proper Doubly linked list structures for each of Three neighbouring cells
            let vertex = Circle(
                p1: prev.point!,
                p2: newArc.point!,
                p3: next.point!
                )!.center
            
            prev.rightHalfEdge?.origin = vertex
            next.leftHalfEdge?.destination = vertex
            
            let lhe = diagram.createHalfEdge(newArc.cell!)
            newArc.leftHalfEdge = lhe
            lhe.origin = vertex
            let lTwin = diagram.createHalfEdge(prev.cell!)
            lTwin.destination = vertex
            makeTwins(lhe, lTwin)
            
            let rhe = diagram.createHalfEdge(newArc.cell!)
            newArc.rightHalfEdge = rhe
            rhe.destination = vertex
            let rTwin = diagram.createHalfEdge(next.cell!)
            rTwin.origin = vertex
            makeTwins(rhe, rTwin)
            
            connect(prev: lTwin, next: prev.rightHalfEdge)
            connect(prev: next.leftHalfEdge, next: rTwin)
            connect(prev: rhe, next: lhe)
            
            prev.rightHalfEdge = lTwin
            next.leftHalfEdge = rTwin
            
            logger?.log("Site Event degenerate case (Breapoint has the same X coordinate as a Site: \(event.point)", level: .warning)
        } else {
            /// Regular and most likely case. Here we break the arc, create **HalfEdge** records and set proper pointers between them
            next.cell = prev.cell
            next.rightHalfEdge = prev.rightHalfEdge

            prev.rightHalfEdge = diagram.createHalfEdge(prev.cell)
            newArc.leftHalfEdge = diagram.createHalfEdge(newArc.cell)
            
            makeTwins(prev.rightHalfEdge, newArc.leftHalfEdge)
            
            newArc.rightHalfEdge = newArc.leftHalfEdge
            next.leftHalfEdge = prev.rightHalfEdge
        }
        
        if let intermediate = self.watcher {
            intermediate.updateBeachline(arcs: beachline.getArcs())
        }
    }
    
    
    /// When Circle event took place we must create a **Vertex** record in the Diagram.
    /// - Create appropriate pointers between colliding arc's HalfEdges (to maintain doubly linked list half edges in the cell)
    /// - Create two new **HalfEdge** records and set pointers between them to create an edge between colliding cells.\
    /// - Parameters:
    ///   - vertex: Vertex coordinate (e.g. Circle event center)
    ///   - removedArc: The arc that will be removed from the **Beachline** after the Circle event
    private func createVertex(_ vertex: Vertex, removedArc: Arc) {
        container.expandToContainPoint(vertex)
        
        let prevArc = removedArc.prev!
        let nextArc = removedArc.next!
        
        /// Finalize removed arc Half edges
        removedArc.leftHalfEdge?.destination = vertex
        removedArc.rightHalfEdge?.origin = vertex
        
        /// Set origin/destination for left colliding arc edge
        prevArc.rightHalfEdge?.origin = vertex
        prevArc.rightHalfEdge?.twin?.destination = vertex
        
        /// Set origin/destination for right colliding arc edge
        nextArc.leftHalfEdge?.destination = vertex
        nextArc.leftHalfEdge?.twin?.origin = vertex
        
        /// Maintain linked list in the removed arc Cell
        connect(
            prev: prevArc.rightHalfEdge?.twin,
            next: nextArc.leftHalfEdge?.twin
        )
        
        /// Create Two new half edges and set proper pointers between them
        let prevRHE = diagram.createHalfEdge(prevArc.cell!)
        prevRHE.destination = vertex
        connect(
            prev: prevRHE,
            next: prevArc.rightHalfEdge
        )
        prevArc.rightHalfEdge = prevRHE

        let nextLHE = diagram.createHalfEdge(nextArc.cell!)
        nextLHE.origin = vertex
        connect(
            prev: nextArc.leftHalfEdge,
            next: nextLHE
        )
        nextArc.leftHalfEdge = nextLHE
        
        makeTwins(prevArc.rightHalfEdge, nextArc.leftHalfEdge)
        
        watcher?.createVertex(vertex: vertex)
    }
    
    
    /// Processes circle event and performs all the necessary actions
    /// - Parameter event: **Circle Event**
    private func processCircleEvent(_ event: Event) {
        logger?.log("Circle Event: \(event.point)", level: .info)
        watcher?.circleEvent(point: event.point)
        
        guard let arc = event.arc,
              let left = arc.prev,
              let right = arc.next
            else {
                return
        }
        let center = event.circle!.center
        
        /// #Step 0:
        /// Update **Sweepline** position
        sweepLineY = event.point.y
        beachline.updateSweeplineY(sweepLineY)
        
        /// #Step 1:
        /// Delete disppearing arc from the Beachline. Tree will rebalance itself.
        beachline.delete(arc: arc)
        removeCircleEvent(arc)
        
        /// #Step 2:
        /// Delete all circle events involving disappearing arc from the **Priority Queue**.
        /// These can be found using the pointers to the `prev` and `next` node in the beachline linked list
        removeCircleEvent(left)
        removeCircleEvent(right)
        
        /// #Step 3:
        /// Add the center of the circle causing the event as a **Vertex** record to the **Voronoi Diagram**
        /// Create two half-edge records corresponding to the new breakpoint of the beach line.
        /// Set the pointers between them appropriately. Attach the three new records to the half-edge records that end at the **Vertex**
        createVertex(center, removedArc: arc)
        
        /// #Step 4:
        /// Check the new triple of consecutive arcs that has the former left neighbor of the removed arc as its middle arc to see if the two breakpoints of the triple *converge*.
        /// If so, insert the corresponding circle event into **Priority Queue** and set pointers between the new circle event in **Priority Queue** and the corresponding **Beachline** node.
        /// Do the same for the triple where the former right neighbor is the middle arc.
        createCircleEvent(left)
        createCircleEvent(right)
    }
    
    /// Creates circle event for the coresponding **Arc** in the **Beachline**
    /// Adds **Circle Event** into **Priority Queue**
    /// Sets ponters between **Circle Event** and **Arc**
    /// - Parameters:
    ///   - arc: **Beachline** arc to add event
    ///   - circle: Circle represented by three points
    private func createCircleEvent(_ arc: Arc) {
        let left = arc.prev
        let right = arc.next
        guard let circle = checkCircleEvent(left: left, mid: arc, right: right) else {
            return
        }
        var event = Event(
            point: circle.bottomPoint,
            kind: .circle
        )
        event.circle = circle
        event.arc = arc
        arc.event = event
        
        eventQueue.push(event)
        
        logger?.log("Create Circle Event for Arc: \(arc.point!)", level: .info)
        watcher?.addUpcomingCircleEvent(circle: event.circle!)
    }
    
    /// Removes circle event from the **Priority Queue** and removes event from the **Arc**
    /// - Parameter arc: **Arc** to strip from **Circle Event**
    private func removeCircleEvent(_ arc: Arc?) {
        guard
            let arc = arc,
            let event = arc.event,
            event.kind == .circle
            else {
                return
        }
        
        watcher?.removeFalseAlarmCircleEvent(circle: event.circle!)
        logger?.log("Remove Circle Event for Arc: \(arc.point!)", level: .info)
        
        eventQueue.removeAll(event)
        arc.event = nil
    }
    
  
    /// Algorithm termination
    /// 1. Bound incomplete arcs to Maximum rectangle
    /// 2. Complete incomplete cells
    /// 3. Clip cells to clipping rectangle
    private func terminate() {
        logger?.log("Event Queue is empty. Diagram bounding started.", level: .info)
        
        // Step 1:
        // Bound incomplete arcs
        var arc: Arc? = beachline.minimum
        while arc != nil {
            boundIncompleteArc(arc!)
            arc = arc?.next
        }
        
        let min = beachline.minimum
        let max = beachline.maximum
        
        if min!.cell === max!.cell {
            if let prev = max?.prev, let next = min?.next {
                max?.leftHalfEdge?.destination = getBoxIntersection(prev.point!, max!.point!, container)
                min?.rightHalfEdge?.origin = getBoxIntersection(min!.point!, next.point!, container)
                
                if let start = min?.rightHalfEdge?.origin, let end = max?.leftHalfEdge?.destination {
                    if let (head, tail) = halfEdgesChain(cell: max!.cell, clippingRect: container, start: end, end: start) {
                        connect(prev: max?.leftHalfEdge, next: head)
                        connect(prev: tail, next: min?.rightHalfEdge)
                    }
                }
            }
        }
        
        for cell in diagram.cells {
            // Step 2:
            // Complete incomplete cells
            if cell.outerComponent?.prev == nil || cell.outerComponent?.next == nil {
                completeIncompleteCell(cell)
            }
            
            // Step 3:
            // Clip cells
            clipCell(cell, clippingRect: clipper)
        }
        
        logger?.log("Done!", level: .info)
    }
    
    /// Some of the cells will not be completed (Are not looped linked list of half-edges)
    /// - Parameter cell: cell to complete
    private func completeIncompleteCell(_ cell: Cell) {
        guard cell.outerComponent != nil else { return }
        var first: HalfEdge! = cell.outerComponent
        var last: HalfEdge! = cell.outerComponent
        
        while first.prev != nil {
            first = first?.prev
        }
        
        while last.next != nil {
            last = last?.next
        }
        
        let clipper = container!.toClipper()
        
        last.destination = lb_clip(last.toSegment()!, clipper: clipper).resultSegment?.b
        first.origin = lb_clip(first.toSegment()!, clipper: clipper).resultSegment?.a
        
        guard let start = last.destination, let end = first.origin else {
            return
        }
        
        if let (head, tail) = halfEdgesChain(cell: cell, clippingRect: container, start: start, end: end) {
            connect(prev: last, next: head)
            connect(prev: tail, next: first)
        }
    }
    
    
    /// Bounds incomplete arcs to the maximum rectangle
    /// Maximum rectangle is a `Rectangle` containing ALL diagram vertexes. It is expanded as
    /// - Parameter arc: `Arc` from the beachline
    private func boundIncompleteArc(_ arc: Arc) {
        var startPoint: Site?
        var endPoint: Site?
        if let prevArc = arc.prev {
            startPoint = getBoxIntersection(prevArc.point!, arc.point!, container)
            prevArc.rightHalfEdge?.origin = startPoint
        }
        
        if let nextArc = arc.next {
            endPoint = getBoxIntersection(arc.point!, nextArc.point!, container)
            nextArc.leftHalfEdge?.destination = endPoint
        }
        
        guard let start = startPoint, let end = endPoint else {
            return
        }

        if let (head, tail) = halfEdgesChain(cell: arc.cell, clippingRect: container, start: start, end: end) {
            connect(prev: arc.leftHalfEdge, next: head)
            connect(prev: tail, next: arc.rightHalfEdge)
        }
    }
    
    
    /// Clips cell agains clipping `Rectangle`. There are few limitations:
    /// - `cell` should be completed (It's half-edges are connected into linked list and looped)
    /// - Parameters:
    ///   - cell: cell to clip
    ///   - clippingRect: clipping rect
    private func clipCell(_ cell: Cell, clippingRect: Rectangle) {
        /// Handle special case when our diagram coinsists of one site and return
        /// Or skip to regular case
        var firstHE: HalfEdge?
        if cell.outerComponent == nil {
            let corners = [clippingRect.tl, clippingRect.bl, clippingRect.br, clippingRect.tr]
            for i in 1...corners.count {
                let he = diagram.createHalfEdge(cell)
                he.origin = corners[i - 1]
                he.destination = corners[i % corners.count]
                
                if i == 1 {
                    firstHE = he
                    cell.outerComponent = he
                }
                
                connect(prev: cell.outerComponent, next: he)
                cell.outerComponent = he
                
            }
            connect(prev: cell.outerComponent, next: firstHE)
            assert(cell.outerComponent?.destination == firstHE?.origin)
            return
        }
        
        
        
        var he = cell.outerComponent
        var hes = [(HalfEdge, Bool, Bool)]()
        var firstOut = -1
        var finish = false
        while !finish {
            guard let segmentToClip = he?.toSegment() else {
                logger?.log("Fatal Error! Malformed Half-Edge!", level: .critical)
                fatalError()
            }
            
            let (isOriginClipped, isDestinationClipped, segment) = lb_clip(segmentToClip, clipper: clippingRect.toClipper())

            if isOriginClipped || isDestinationClipped {
                if isDestinationClipped {
                    if firstOut < 0 {
                        firstOut = hes.count
                    }
                    he?.destination = segment?.b
                }
                if isOriginClipped {
                    he?.origin = segment?.a
                }
                hes.append((he!, isOriginClipped, isDestinationClipped))
            }
            
            he = he?.next
            finish = he === cell.outerComponent
        }
        
        var i = firstOut
        while i < (hes.count + firstOut) {
            let curIdx = i % hes.count
            let nextIdx = (i+1) % hes.count
            
            if let (head, tail) = halfEdgesChain(
                cell: cell,
                clippingRect: clipper,
                start: hes[curIdx].0.destination!,
                end: hes[nextIdx].0.origin!
            ) {
                cell.outerComponent = hes[curIdx].0
                connect(prev: hes[curIdx].0, next: head)
                connect(prev: tail, next: hes[nextIdx].0)
            }
            
            if hes[nextIdx].2 == true {
                i += 1
            } else {
                i += 2
            }
        }
    }
    
    
    /// Returns linked list of half-edges belonging to the clipping rect (maximum 4) represented as a pair
    /// - Starting half-edge (head)
    /// - Finishing half-edge (tail)
    /// - Parameters:
    ///   - cell: half-edges owning `Cell`
    ///   - clippingRect: Clipping rectangle
    ///   - start: head origin
    ///   - end: tail destination
    private func halfEdgesChain(
        cell: Cell,
        clippingRect: Rectangle,
        start: Site,
        end: Site
    ) -> (HalfEdge, HalfEdge)? {
        let points = clippingRect.getRectPolylineForCCW(start, end: end)
        
        let head = diagram.createHalfEdge(cell)
        head.origin = start
        
        var he = head
        for point in points {
            he.destination = point
            
            let newHE = diagram.createHalfEdge(cell)
            newHE.origin = point
            
            connect(prev: he, next: newHE)
            he = newHE
        }
        he.destination = end
        return (head, he)
    }
    
    /// Finds the intersection point for the bisector of the Line Segment defined by two points and Rectangle
    /// - Parameters:
    ///   - p1: Point
    ///   - p2: Point
    ///   - rectangle: Rectangle
    private func getBoxIntersection(
        _ p1: Site,
        _ p2: Site,
        _ rectangle: Rectangle
    ) -> Site {
        rectangle.intersection(
            origin: ((p1.vector + p2.vector) * 0.5).point,
            direction: (p1.vector - p2.vector).normal
        ).point
    }
        
    /// When the Cell has common edge with another cell, thir corresponding **HalfEdges** are twins.
    /// It means they have a pointer to each other and `a.origin == b.destination` and vice versa
    /// This helper sets appropriate pointers between half edges
    private func makeTwins(_ a: HalfEdge?, _ b: HalfEdge?) {
        a?.twin = b
        b?.twin = a
    }
    
    
    /// Each cell is represented as **Doubly connected** linked list of **HalfEdges**
    /// This helper connects two half edges appropriately
    private func connect(prev: HalfEdge?, next: HalfEdge?) {
        prev?.next = next
        next?.prev = prev
    }
    
    
    // MARK: - Circle event check -
    
    /// Receives three arcs as an input and returns a circle, if the arc's points are not collinear and converging.
    /// Convergence means that at some point `mid` arc will be removed (Circle event will take place)
    /// Keep in mind that the fact that three points define a circle is not enough for circle event to take place
    /// - Parameters:
    ///   - left: left arc
    ///   - mid: middle arc
    ///   - right: right arc
    private func checkCircleEvent(left: Arc?, mid: Arc, right: Arc?) -> Circle? {
        guard
            let a = left?.point,
            let b = mid.point,
            let c = right?.point,
            let circle = Circle(p1: a, p2: b, p3: c) else {
                return nil
        }
        
        /// If the determinant is negative, then the polygon is oriented clockwise. If the determinant is positive, the polygon is oriented counterclockwise. The determinant is non-zero if points A, B, and C are non-collinear. In the above example, with points ordered A, B, C, etc., the determinant is negative, and therefore the polygon is clockwise.
        let determinant = (b.x * c.y + a.x * b.y + a.y * c.x) - (a.y * b.x + b.y * c.x + a.x * c.y)
        
        /// Only add events with bottom point below the sweep line
        let eventY = circle.center.y + circle.radius
        
        /// We are only interested in events below or on the sweepLine
        if eventY >= sweepLineY && determinant > 0 {
            return circle
        }
        
        return nil
    }
}



// MARK: - Helpers and extensions -
extension Site {
    var vector: Vector2D {
        Vector2D(dx: x, dy: y)
    }
}

extension Vector2D {
    var normal: Vector2D {
        Vector2D(dx: -dy, dy: dx)
    }
    
    var point: Site {
        Site(x: dx, y: dy)
    }
}

public struct BeachlineSegment {
    let parabola: Parabola
    let lBoundX: Double
    let rBoundX: Double
}

extension Beachline {
    public func getArcs() -> [BeachlineSegment] {
        var arcs = [BeachlineSegment]()
        var arc = minimum
        while arc != nil {
            let (lb, rb) = arc!.bounds(sweeplineY)
            arcs.append(
                BeachlineSegment(
                    parabola: Parabola(focus: arc!.point!, directrixY: sweeplineY),
                    lBoundX: lb,
                    rBoundX: rb
                )
            )
            arc = arc?.next
        }
        return arcs
    }
}
