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

    var prefersWindowCoordinates: Bool { return true }
    
    init(withSupport support: MouseSupport) {
        self.support = support
    }

    func move(to: CGPoint, modifierFlags: NSEvent.ModifierFlags) {
        let now = Date()
        let delta = now.timeIntervalSince(lastMoved)

        if delta < moveThrottle {
            return
        }
        lastMoved = now

        print("move to \(to) flags \(modifierFlags)")

        /*
         let bubble = bubbleSoup.hitTestBubble(at: viewLocation)
         highlightBubble(bubble)
         */
    }
}

