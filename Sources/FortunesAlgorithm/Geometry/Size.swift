//
//  Created by Oleksandr Glagoliev on 17/06/2019.
//  Copyright © 2019 Oleksandr Glagoliev. All rights reserved.
//

import Foundation


/// Represents the size of Rectangular object
public struct Size {
    var width: Double
    var height: Double
    
    public init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }
}

extension Size: CustomStringConvertible {
    public var description: String {
        return "(width: \(width), height: \(height))"
    }
}
