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

public protocol VoronoiDebugging: class {
    var notVisitedSites: [Site] { get set }
    var visitedSites: [Site] { get set }
    var sweeplineY: Double { get set }
    var currentBreakpoint: Site? { get set }
    var circles: [Circle] { get set }
    var upcomingCircleEvents: [Site] { get set }
    var container: Rectangle? { get set }
    var arcs: [
        (
            parabola: Parabola,
            lBound: Double,
            rBound: Double
        )
        ] { get set }
    var box: Rectangle? { get set }
    var potentialEdges: [LineSegment] { get set }
    var numSteps: Int? { get set }
    var curStep: Int { get set }
}
