import Foundation
import Darwin

public class FortuneSweep {
    /// Service Data Structures
    private var eventQueue: PriorityQueue<Event>!
    private var beachline: Beachline!
    private var sweepLineY = Double(0)
    private var firstSiteY: Double?
    
    private(set) var container: Rectangle!
    private var clipper: Rectangle!
    
    /// Result Data Structure
    private(set) var diagram = VoronoiDiagram()
    
    /// Debug Data Structure
    private(set) var status = VoronoiStatus()
    private var curStep: Int = -1
    
    
    public init() { }
    
    public func compute(
        sites: Set<Site>,
        diagram: inout VoronoiDiagram,
        status: inout VoronoiStatus,
        clippingRect: Rectangle,
        numSteps: Int = -1
    ) {
        self.diagram = diagram
        self.status = status
        self.clipper = clippingRect
        
        status.box = clippingRect
        
        sweepLineY = 0
        firstSiteY = nil
        beachline = Beachline()
        
        if sites.count < 2 {
//            print("NOTHING TO COMPUTE!")
            return
        }
        
        eventQueue = PriorityQueue(
            ascending: true,
            startingValues: sites.map { Event(point: $0) }
        )
        
        // Debug
        curStep = 0
        status.notVisitedSites = sites.map { $0 }
        
        var finished = false
        while !finished {
            step()
            finished = eventQueue.isEmpty || (numSteps > 0 && curStep == numSteps)
        }
        if eventQueue.isEmpty {
            terminate()
        }
    }
    
    
    /// Performs one step of the algorithm
    /// 1. Pop an event from the event queue
    /// 2. Check the event type and process the event appropriately
    private func step() {
        curStep += 1
        if let event = eventQueue.pop() {
            switch event.kind {
                case .site:
                    processSiteEvent(event)
                case .circle:
                    processCircleEvent(event)
            }
        }
        // Debug
//        print("""
//            Step: \(curStep)
//
//            """)
    }
    
    
    /// Processes **Site event** and performs all the necessary actions
    /// - Parameter event: **Site Event** to process
    private func processSiteEvent(_ event: Event) {
        
        /// Ignore ceells that are not contained by Clipping Rectangle
        guard clipper.contains(event.point) else {
            return
        }
        
        /// #Step 1:
        /// Update **Sweepline** position
        sweepLineY = event.point.y
        beachline.updateSweeplineY(sweepLineY)
        
        // Debug
        status.circles.removeAll() // Clear circle event drawing
        status.sweeplineY = sweepLineY
        status.visitedSites.append(event.point)
//        print("SITE EVENT: \(event.point)")
        
        /// #Step 2:
        /// Each **Site Event** makes new arc(s) to appear in the **Beachline**
        /// There are few possible cases:
        
        /// Case 1: (Always present once)
        /// Beachline is empty. Create beachline root Arc and return
        if beachline.isEmpty {
            let root = beachline.insertRootArc(point: event.point)
            firstSiteY = event.point.y
            container = clipper
            
            /// Create new **Cell** record in **Voronoi Diagram**
            container.expandToContainPoint(event.point)
            diagram.createCell(root)
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
            container.expandToContainPoint(event.point)
            let yVal: Double = .leastNormalMagnitude
            let arc = beachline.handleSpecialArcInsertionCase(event.point)

            /// 1. Create new **Cell** record in **Voronoi Diagram**
            diagram.createCell(arc)

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

            // Debug
//            print("DEGENERATE CASE")
            beachline.printDOTFormat()
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
        
        // Debug
        let parabola = Parabola(focus: newArc.prev!.point!, directrixY: sweepLineY)
        let breakPoint = Site(
            x: event.point.x,
            y: parabola.resolve(x: event.point.x)
        )
//        print("Breakpoint found: \(breakPoint)")
        status.currentBreakpoint = breakPoint
        
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
//            diagram.addVertex(vertex)
            
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
        
        // Debug
        beachline.printDOTFormat()
        status.arcs = beachline.getArcs()
    }
    
    
    /// When Circle event took place we must create a **Vertex** record in the Diagram.
    /// - Create appropriate pointers between colliding arc's HalfEdges (to maintain doubly linked list half edges in the cell)
    /// - Create two new **HalfEdge** records and set pointers between them to create an edge between colliding cells.\
    /// - Parameters:
    ///   - vertex: Vertex coordinate (e.g. Circle event center)
    ///   - removedArc: The arc that will be removed from the **Beachline** after the Circle event
    private func createVertex(_ vertex: Vertex, removedArc: Arc) {
//        diagram.addVertex(vertex)
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
    }
    
    
    /// Processes circle event and performs all the necessary actions
    /// - Parameter event: **Circle Event**
    private func processCircleEvent(_ event: Event) {
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
        
        // Debug
        status.currentBreakpoint = nil
        status.sweeplineY = sweepLineY
//        print("CIRCLE EVENT: \(event.point)")
        
        /// #Step 1:
        /// Delete disppearing arc from the Beachline. Tree will rebalance itself.
        beachline.delete(arc: arc)
        removeCircleEvent(arc)
        
        // Debug
//        print("REMOVE ARC: \(arc)")
        
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
        
        // Debug
        beachline.printDOTFormat()
        status.arcs = beachline.getArcs()
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
        
        // Debug
        status.circles.append(circle)
        status.upcomingCircleEvents.append(circle.bottomPoint)
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
        
        eventQueue.removeAll(event)
        arc.event = nil
        
        // Debug
//        print("REMOVE CIRCLE EVENT: \(event)")
        if let circle = event.circle {
            status.upcomingCircleEvents = status.upcomingCircleEvents.filter { $0 != circle.bottomPoint }
        }
    }
    
  
    /// Algorithm termination
    /// 1. Bound incomplete arcs to Maximum rectangle
    /// 2. Complete incomplete cells
    /// 3. Clip cells to clipping rectangle
    private func terminate() {
//        print("""
//            -------------------------
//            TERMINATION:
//            -------------------------
//            """)
        
        if diagram.cells.count < 1 {
//            print("EMPTY DIAGRAM!")
            return
        }
        
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
        
        for cell in diagram.cells.values {
            // Step 2:
            // Complete incomplete cells
            if cell.outerComponent?.prev == nil || cell.outerComponent?.next == nil {
                completeIncompleteCell(cell)
            }
            
//            if !clipper.contains(cell.site) {
//                diagram.removeCell(cell)
//            }
            
            // Step 3:
            // Clip cells
            if cell.outerComponent != nil {
                clipCell(cell, clippingRect: clipper)
            }
        }
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
        
        last.destination = lb_clip(last.toSegment()!, clipper: clipper).resultSegment!.b
        first.origin = lb_clip(first.toSegment()!, clipper: clipper).resultSegment!.a
        
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
        var pairsToConnect = [(start: HalfEdge?, end: HalfEdge?)]()
        var start: HalfEdge?
        var end: HalfEdge?
        
        
        var he = cell.outerComponent
        while true {
            guard let segmentToClip = he?.toSegment() else {
                fatalError("[FATAL ERROR]: Cannot create segment from the `HalfEdge`!")
            }
            
            let (isOriginClipped, isDestinationClipped, segment) = lb_clip(segmentToClip, clipper: clippingRect.toClipper())

            if isOriginClipped && isDestinationClipped {
                he?.origin = segment!.a
                he?.destination = segment!.b
                pairsToConnect.append(
                    (start: he, end: he)
                )
            } else if isDestinationClipped {
                start = he
                start?.destination = segment!.b
                diagram.addVertex(segment!.b)
            } else if isOriginClipped {
                end = he
                end?.origin = segment!.a
                diagram.addVertex(segment!.a)
            }
            
        

            if let s = start, let e = end {
                pairsToConnect.append(
                    (start: s, end: e)
                )
            }
            
            he = he?.next
            if he === cell.outerComponent || he?.next == nil {
                break
            }
        }
        
        pairsToConnect.forEach {
            if let (head, tail) = halfEdgesChain(cell: cell, clippingRect: clipper, start: $0.start!.destination!, end: $0.end!.origin!) {
                cell.outerComponent = $0.start
                connect(prev: $0.start, next: head)
                connect(prev: tail, next: $0.end)
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
//            diagram.addVertex(point)
            
            let newHE = diagram.createHalfEdge(cell)
            newHE.origin = point
            
            connect(prev: he, next: newHE)
            he = newHE
        }
        he.destination = end
//        diagram.addVertex(end)
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
extension FortuneSweep {
    func run(maxSteps: Int) {
        var curStep = 0
        if maxSteps > 0 {
            while curStep != maxSteps {
                step()
                curStep += 1
            }
        } else {
            while !eventQueue.isEmpty {
                step()
            }
        }
        
        if eventQueue.isEmpty {
            terminate()
        }
    }
    
    @objc
    public func debugStep() {
        step()
        
        if eventQueue.isEmpty {
            terminate()
        }
    }
}

extension Site {
    var vector: Vector2D {
        Vector2D(dx: x, dy: y)
    }
}

extension Vector2D {
    var normal: Vector2D {
        return Vector2D(dx: -dy, dy: dx)
    }
    
    var point: Site {
        return Site(x: dx, y: dy)
    }
}
