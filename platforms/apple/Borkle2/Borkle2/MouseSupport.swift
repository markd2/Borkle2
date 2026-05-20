/// Support for Mouse Stuffs - adapted from Borkle1

import Cocoa

protocol MouseHandler {
    func start(at: CGPoint, modifierFlags: NSEvent.ModifierFlags)
    func drag(to: CGPoint, modifierFlags: NSEvent.ModifierFlags)
    func finish(at: CGPoint, modifierFlags: NSEvent.ModifierFlags)

    func move(to: CGPoint, modifierFlags: NSEvent.ModifierFlags)

    var prefersWindowCoordinates: Bool { get }
}

extension MouseHandler {
    func start(at: CGPoint, modifierFlags: NSEvent.ModifierFlags) { }
    func drag(to: CGPoint, modifierFlags: NSEvent.ModifierFlags) { }
    func finish(at: CGPoint, modifierFlags: NSEvent.ModifierFlags) { }
    func move(to: CGPoint, modifierFlags: NSEvent.ModifierFlags) { }
}

protocol MouseSupport {
    var currentScrollOffset: CGPoint { get }
    func scroll(to: CGPoint)

    func hitTestBubble(at: CGPoint) -> Bubble?

    func hoveredBubble(bubbleID: BubbleID?) // nil if over empty space

/* FOR THE FUTURE
    func areaTestBubbles(intersecting: CGRect) -> [Bubble]?
    func drawMarquee(around: CGRect)

    func unselectAll()
    func select(bubbles: [Bubble])
    
    // set to a selection to make them render less opaque, like for dragging.
    // set nil to revert to everyone fully opaque
    func makeTransparent(_ selection: Selection?)

    func createNewBubble(at point: CGPoint, showEditor: Bool) -> Bubble

    func connect(bubbles: [Bubble], to: Bubble)
    func disconnect(bubbles: [Bubble], from: Bubble)

    // renaming to "hoveredBubble"
    func highlightAsDropTarget(bubble: Bubble?) // nil to remove highlight

    func bubblesAffectedBy(barrier: Barrier) -> [Bubble]?
    func barriersAffectedBy(barrier: Barrier) -> [Barrier]?
    func move(bubble: Bubble, to: CGPoint)
    func move(barrier: Barrier, 
              affectedBubbles: [Bubble]?, affectedBarriers: [Barrier]?,
              to horizontalPosition: CGFloat)
*/
}


extension MouseHandler {
    var prefersWindowCoordinates: Bool { return false }

    func hoveredBubble(bubbleID: BubbleID?) { }
}
