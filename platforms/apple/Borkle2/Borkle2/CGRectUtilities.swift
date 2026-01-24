// CGRectUtilities.swift: utilities for cgrect

import Foundation

extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}
