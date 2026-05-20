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

    /// Don't retrigger on the same state.
    var lastBubbleID: BubbleID? = Bubble.illegalID  // nil for no current bubble

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
            if lastBubbleID == nil || bubble.ID != lastBubbleID! {
                lastBubbleID = bubble.ID
                support.hoveredBubble(bubbleID: lastBubbleID)
            }
        } else {
            if lastBubbleID != nil {
                lastBubbleID = nil
                support.hoveredBubble(bubbleID: lastBubbleID)
            }
        }
    }
}

