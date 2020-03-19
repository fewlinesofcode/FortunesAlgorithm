//
//  Created by Oleksandr Glagoliev on 5/29/19.
//  Copyright © 2019 Oleksandr Glagoliev. All rights reserved.
//
import Foundation

/// Event
struct Event {
    enum Kind {
        case site
        case circle
    }
    
    var kind: Kind
    let point: Site
    
    // Circle event only
    weak var arc: Arc?
    var circle: Circle?
    
    init(point: Site, kind: Kind = .site) {
        self.kind = kind
        self.point = point
    }
}

extension Event: Comparable {
    static func == (lhs: Event, rhs: Event) -> Bool {
        lhs.point == rhs.point && lhs.kind == rhs.kind
    }
    
    static func < (lhs: Event, rhs: Event) -> Bool {
        if lhs.point.y == rhs.point.y {
            return lhs.point.x < rhs.point.x
        }
        return lhs.point.y < rhs.point.y
    }
}
