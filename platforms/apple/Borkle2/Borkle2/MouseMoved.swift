/// MouseMoved.swift - high-level handler for when the mouse gets moved
/// in a view.

import AppKit

/// Currently, highlights the bubble the mouse is over.

class MouseMoved: MouseHandler {
    private var support: MouseSupport

    /// We get absolutely hammered with mouse moved events, throttle
    /// them down to a more reasonable rate.  We may lose some granular
    /// movement, but I think this is an acceptable tradeoff
    var moveThrottle: TimeInterval = 0.05
    var lastMoved: Date = Date()

    var prefersWindowCoordinates: Bool { return false }
    
    init(withSupport support: MouseSupport) {
        self.support = support
    }

    func move(to point: CGPoint, modifierFlags: NSEvent.ModifierFlags) {
        let now = Date()
        let delta = now.timeIntervalSince(lastMoved)

        if delta < moveThrottle {
            return
        }
        lastMoved = now

        let bubble = support.hitTestBubble(at: point)

        if let bubble = bubble {
            print("got a bubble \(bubble.title!)")
        } else {
            print("no bubble I")
        }
    }
}

