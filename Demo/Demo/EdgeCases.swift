//
//  EdgeCases.swift
//  Demo
//
//  Created by Oleksandr Glagoliev on 3/10/20.
//  Copyright © 2020 Oleksandr Glagoliev. All rights reserved.
//

import Foundation

var edgeCases = [
    broken0,
    broken,
    testSites_3,
    testSites_4,
    testSites_5,
    testSites_6,
    randomSites(2, xRange: 100..<300, yRange: 50..<300),
    randomSites(3, xRange: 100..<300, yRange: 50..<300),
    randomSites(30, xRange: 100..<300, yRange: 50..<300),
    randomSites(200, xRange: 100..<300, yRange: 50..<300),
    randomSites(500, xRange: 50..<500, yRange: 50..<700),
]

var gridLike: [Site] {
    var res = [Site]()
    for i in 0..<Int(10) {
        for j in 0..<Int(10) {
            res.append(
                Site(x:(Double(i) + 0.5) * 40, y:(Double(j) + 0.5) * 40)
            )
        }
    }
    return res
}

var hellLike: [Site] {
    var res = [Site]()
    for i in 0..<Int(10) {
        for j in 0..<Int(10) {
            res.append(
                Site(
                    x:Double(i) * 40,
                    y:Double(j) * 40 + ((i % 2 == 0 && j % 2 == 1) ? 40 : 0)
                )
            )
        }
    }
    return res
}

var hexLike: [Site] {
    var res = [Site]()
    for i in 0..<Int(10) {
        for j in 0..<Int(10) {
            res.append(
                Site(
                    x:Double(i) * 40 + Double(j) * 20,
                    y:Double(j) * 40
                )
            )
        }
    }
    return res
}


let testSites_3 = Set<Site>(
    gridLike.map {
        Site(x: $0.x + 200, y: $0.y + 200)
    }
)

let testSites_4 = Set<Site>(
    (0...10).map {
        Site(x: Double($0) * 10, y: Double($0) * 10)
    }.map {
        Site(x: $0.x + 200, y: $0.y + 200)
    } // Diagonal
)

let testSites_5 = Set<Site>(
    hexLike.map {
        Site(x: $0.x + 200, y: $0.y + 200)
    }
)

let testSites_6 = Set<Site>(
    hellLike.map {
        Site(x: $0.x + 200, y: $0.y + 200)
    }
)

let broken = Set<Site>(
    [
//        Site(x: 508.0, y: 540.0),
//        Site(x: 481.0, y: 514.0),
//        Site(x: 370.0, y: 391.0),
//        Site(x: 344.0, y: 361.0),
//        Site(x: 324.0, y: 341.0),
//        Site(x: 314.0, y: 327.0),
//        Site(x: 297.0, y: 310.0),
//        Site(x: 279.0, y: 288.0),
        Site(x: 251.0, y: 270.0),
        Site(x: 234.0, y: 248.0),
        Site(x: 204.0, y: 202.0),
        Site(x: 166.0, y: 153.0),
    ]
)
    
let broken0 = Set<Site>(
    [
        Site(x: 241.0, y: 293.0),
        Site(x: 166.0, y: 192.0),
    ]
)

