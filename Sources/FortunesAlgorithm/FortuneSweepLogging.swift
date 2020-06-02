//
//  Logging.swift
//  Voronoi
//
//  Created by Oleksandr Glagoliev on 28.03.2020.
//  Copyright © 2020 Oleksandr Glagoliev. All rights reserved.
//

import Foundation


/// <#Description#>
public enum FortuneSweppLogLevel {
    case info
    case warning
    case error
    case critical
}


public protocol FortuneSweepLogging {
    
    /// Depending on implemntation prints/saves log messages
    /// - Parameters:
    ///   - text: Log message
    ///   - level: Log level
    func log(_ message: String, level: FortuneSweppLogLevel)
}
