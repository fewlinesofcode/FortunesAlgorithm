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


final class Arc {
    var isBlack: Bool = true
    
    private(set) var point: Site?
    var event: Event?
    unowned var prev: Arc?
    unowned var next: Arc?
    
    var leftHalfEdge: HalfEdge?
    var rightHalfEdge: HalfEdge?
    weak var cell: Cell!
    
    var right: Arc?
    var left: Arc?
    unowned var parent: Arc?
    
    init(point: Site) {
        self.point = point
    }
    
    init() { }
}

final class Beachline {
    var sweeplineY: Double = 0
    
    private var root: Arc?
    private let sentinel: Arc
    
    init() {
        sentinel = Arc()
        root = nil
    }
    
    private func minimum(_ x: Arc) -> Arc {
        var x = x
        while x.left !== sentinel {
            x = x.left!
        }
        return x
    }
    
    private func maximum(_ x: Arc) -> Arc {
        var x = x
        while x.right !== sentinel {
            x = x.right!
        }
        return x
    }
    
    private func delete(_ z: Arc) {
        var y = z
        var yOriginalColorIsBlack = y.isBlack
        var x: Arc!
        if z.left === sentinel {
            x = z.right
            transplant(z, z.right!)
        } else if z.right === sentinel {
            x = z.left
            if z.left !== sentinel {
                transplant(z, z.left!)
            }
        } else {
            y = minimum(z.right!)
            yOriginalColorIsBlack = y.isBlack
            x = y.right
            if y.parent === z {
                x.parent = y
            } else {
                transplant(y, y.right!)
                y.right = z.right
                y.right!.parent = y
            }
            transplant(z, y)
            y.left = z.left
            y.left?.parent = y
            y.isBlack = z.isBlack
        }
        if yOriginalColorIsBlack {
            deleteFixup(x)
        }
    }
    
    private func insertFixup(_ z: Arc) {
        
        var z = z
        while z.parent?.isBlack == false {
            if z.parent === z.parent?.parent?.left {
                let y = z.parent!.parent!.right
                if y?.isBlack == false {
                    z.parent!.isBlack = true
                    y!.isBlack = true
                    z.parent!.parent!.isBlack = false
                    z = z.parent!.parent!
                } else {
                    if z === z.parent!.right {
                        z = z.parent!
                        leftRotate(z)
                    }
                    z.parent!.isBlack = true
                    z.parent!.parent!.isBlack = false
                    rightRotate(z.parent!.parent!)
                }
            } else if z.parent === z.parent?.parent?.right {
                let y = z.parent?.parent?.left
                if y?.isBlack == false {
                    z.parent!.isBlack = true
                    y!.isBlack = true
                    z.parent!.parent!.isBlack = false
                    z = z.parent!.parent!
                } else {
                    if z === z.parent!.left {
                        z = z.parent!
                        rightRotate(z)
                    }
                    z.parent!.isBlack = true
                    z.parent!.parent!.isBlack = false
                    leftRotate(z.parent!.parent!)
                }
            }
        }
        root!.isBlack = true
    }
    
    private func deleteFixup(_ x: Arc) {
        var x = x
        while x !== root && x.isBlack == true {
            if x === x.parent?.left {
                var w = x.parent?.right
                if w?.isBlack == false {
                    w?.isBlack = true
                    x.parent?.isBlack = false
                    leftRotate(x.parent!)
                    w = x.parent?.right
                }
                if w?.left?.isBlack == true && w?.right?.isBlack == true {
                    w?.isBlack = false
                    x = x.parent!
                } else {
                    if w?.right?.isBlack == true {
                        w?.left?.isBlack = true
                        w?.isBlack = false
                        rightRotate(w!)
                        w = x.parent?.right
                    }
                    w?.isBlack = x.parent!.isBlack
                    x.parent?.isBlack = true
                    w?.right?.isBlack = true
                    leftRotate(x.parent!)
                    x = root!
                }
            } else if x === x.parent?.right {
                var w = x.parent?.left
                if w?.isBlack == false {
                    w?.isBlack = true
                    x.parent?.isBlack = false
                    rightRotate(x.parent!)
                    w = x.parent?.left
                }
                if w?.right?.isBlack == true && w?.left?.isBlack == true {
                    w?.isBlack = false
                    x = x.parent!
                } else {
                    if w?.left?.isBlack == true {
                        w?.right?.isBlack = true
                        w?.isBlack = true
                        leftRotate(w!)
                        w = x.parent?.left
                    }
                    w?.isBlack = x.parent!.isBlack
                    x.parent?.isBlack = true
                    w?.left?.isBlack = true
                    rightRotate(x.parent!)
                    x = root!
                }
            }
        }
        x.isBlack = true
    }
    
    private func rightRotate(_ x: Arc) {
        let y = x.left
        x.left = y?.right //reassign g
        if y?.right !== sentinel {
            y?.right?.parent = x //reassign g's parent
        }
        y?.parent = x.parent //reassign the subtree's parent
        if x.parent === sentinel { //if the root is the root of the tree
            root = y
        } else if x === x.parent?.right { //reassign the original root parent's child node
            x.parent?.right = y
        } else if x === x.parent?.left {
            x.parent?.left = y
        }
        //establish parent/child relationship between old and new root nodes
        y?.right = x
        x.parent = y
    }
    
    private func leftRotate(_ x: Arc) {
        let y = x.right
        x.right = y?.left
        
        if y?.left !== sentinel {
            y?.left?.parent = x
        }
        y?.parent = x.parent
        
        if x.parent === sentinel {
            root = y
        } else if x === x.parent?.left {
            x.parent?.left = y
        } else if x === x.parent?.right {
            x.parent?.right = y
        }
        y?.left = x
        x.parent = y
    }
    
    private func transplant(_ u: Arc, _ v: Arc) {
        if u.parent === sentinel {
            root = v
        } else if u === u.parent?.left {
            u.parent?.left = v
        } else if u === u.parent?.right {
            u.parent?.right = v
        }
        v.parent = u.parent
    }
}


// MARK: - Beachline implementation -
extension Arc {
    func bounds(_ directrixY: Double) -> (left: Double, right: Double) {
        var lBound: Double = -Double.infinity
        var rBound: Double = Double.infinity
        
        let parabola = Parabola(focus: point!, directrixY: directrixY)
        
        if let prev = self.prev {
            let lParabola = Parabola(focus: prev.point!, directrixY: directrixY)
            if let intesectionX = lParabola.intersectionX(parabola) {
                lBound = intesectionX
            }
        }
        
        if let next = self.next {
            let rParabola = Parabola(focus: next.point!, directrixY: directrixY)
            if let intesectionX = parabola.intersectionX(rParabola) {
                rBound = intesectionX
            }
        }
        
        return (left: lBound, right: rBound)
    }
}


extension Beachline {
    var isEmpty: Bool {
        root == nil
    }
    // Insert into Beachline
    @discardableResult
    func insertRootArc(point: Site) -> Arc {
        root = Arc(point: point)
        root?.left = sentinel
        root?.right = sentinel
        root?.parent = sentinel
        root?.isBlack = true
        return root!
    }
    
    func updateSweeplineY(_ y: Double) {
        sweeplineY = y
    }
    
//    private func arcAbovePoint(_ p: Point) -> Arc {
//        var x: Arc = root!
//        var found = false
//        while !found {
//            assert(x.point != nil)
//            let (l, r) = x.bounds(sweeplineY)
//            if p.x < l {
//                x = x.left!
//            } else if p.x > r {
//                x = x.right!
//            }
//            else if abs(p.x - l) < eps {
//                x = x.prev!
//                found = true
//            } else if abs(p.x - r) < eps {
//                found = true
//            }
//            else {
//                found = true
//            }
//        }
//        return x
//    }
    
    func addAsLeftChild(_ x: Arc, _ y: Arc) {
        y.left = x
        x.parent = y
        
        x.left = sentinel
        x.right = sentinel
        x.isBlack = false
        
        insertFixup(x)
    }
    
    func addAsRightChild(_ x: Arc, _ y: Arc) {
        y.right = x
        x.parent = y
        
        x.left = sentinel
        x.right = sentinel
        x.isBlack = false
        
        insertFixup(x)
    }
    
    func insertArcForPoint(_ p: Site) -> (Arc, Bool) {
        let mid = Arc(point: p)
        
        var x: Arc = root!
        var found = false
        var isEdgeCase = false
        while !found {
            assert(x.point != nil)
            let (l, r) = x.bounds(sweeplineY)
            if p.x < l {
                x = x.left!
            } else if p.x > r {
                x = x.right!
            }
            else if abs(p.x - l) < eps {
                insertSuccessor(x.prev!, s: mid)
                isEdgeCase = true
                found = true
            } else if abs(p.x - r) < eps {
                insertSuccessor(x, s: mid)
                isEdgeCase = true
                found = true
            }
            else {
                insertSuccessor(x, s: mid)
                let right = Arc(point: x.point!)
                insertSuccessor(mid, s: right)
                isEdgeCase = false
                found = true
            }
        }
        return (mid, isEdgeCase)
    }
    
    
    func handleSpecialArcInsertionCase(_ p: Site) -> Arc {
        let arc = Arc(point: p)
        var current: Arc! = root
        var found = false
        while !found {
            if current.next != nil {
                current = current.next
            } else {
                found = true
            }
        }
        insertSuccessor(current, s: arc)
        return arc
    }
    
    func insertSuccessor(_ p: Arc, s: Arc) {
        s.prev = p
        s.next = p.next
        
        p.next = s
        s.next?.prev = s
        
        if p.right === sentinel {
            addAsRightChild(s, p)
        } else {
            var r = p.right!
            while r.left !== sentinel {
                r = r.left!
            }
            addAsLeftChild(s, r)
        }
    }
    
    func delete(arc: Arc) {
        let prev = arc.prev
        let next = arc.next
        
        prev?.next = next
        next?.prev = prev
        
        delete(arc)
    }
    
    var minimum: Arc? {
        guard let r = root, r !== sentinel else {
            return nil
        }
        return minimum(r)
    }
    
    var maximum: Arc? {
        guard let r = root, r !== sentinel else {
            return nil
        }
        return maximum(r)
    }
}
