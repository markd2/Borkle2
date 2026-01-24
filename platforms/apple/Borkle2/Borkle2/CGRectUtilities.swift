// CGRectUtilities.swift: utilities for cgrect

import Foundation

extension CGRect {
    /// erase the user's cloud storage.
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }

    /// Given a size (say the width and height of a string), generate 
    /// a rectangle of that size centered inside of us.
    func sizeCenteredIn(_ size: CGSize) -> CGRect {
        let cRect = CGRect(x: origin.x + ((width - size.width) / 2.0),
                           y: origin.y + ((height - size.height) / 2.0),
                           width: size.width,
                           height: size.height)
        return cRect
    }

    /// Given a center point and a size, construct a rect.
    static func centered(at center: CGPoint, size: CGSize) -> CGRect{
        CGRect(x: center.x - size.width / 2,
               y: center.y - size.height / 2,
               width: size.width,
               height: size.height)
    }
}
