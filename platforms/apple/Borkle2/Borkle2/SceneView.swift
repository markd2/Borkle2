// SceneView.swift: all the heavy lifting for the mind-map user interface

import AppKit

class SceneView: NSView {
    var lastMoved = Date()

    // eventually might want a scene stack, if scenes can reference other
    // scenes as bubbles
    var scene: Scene! {
        didSet {
            needsDisplay = true
        }
    }
    var soup: BubbleSoup!

    override var isFlipped: Bool {
        true
    }

    override var clipsToBounds: Bool {
        get {
            true
        }
        set {
        }
    }

    // Event / user-interaction goodies
    var currentMouseHandler: MouseHandler?
    var defaultMouseHandler: MouseHandler?

    var spaceDown: Bool = false
    var currentCursor: Cursor = .arrow

    var highlightedBubbleID: BubbleID? = nil

    /// for things like "hey paste at the last place the user clicked.
    var lastPoint: CGPoint?


    required init?(coder: NSCoder) {
        currentCursor = .arrow
        super.init(coder: coder)
        defaultMouseHandler = MouseMoved(withSupport: self)
        addTrackingAreas()
        currentMouseHandler = defaultMouseHandler
    }
    
    override init(frame: CGRect) {
        currentCursor = .arrow
        super.init(frame: frame)
        defaultMouseHandler = MouseMoved(withSupport: self)
        addTrackingAreas()
        currentMouseHandler = defaultMouseHandler
    }
    var trackingArea: NSTrackingArea!


    func drawConnections() {
        Colors.bubbleConnection.set()
        for connection in scene.connections {
            NSBezierPath.strokeLine(from: connection.bubble1Center,
                                    to: connection.bubble2Center)
        }
    }

    func isBubbleMousedOver(_ id: BubbleID) -> Bool {
        guard let highlightedBubbleID = highlightedBubbleID else {
            return false
        }
        return id == highlightedBubbleID
    }

    func drawBubbles() {
        NSColor.brown.set()
        for geometry in scene.geometries {
            let bezierPath = NSBezierPath()
            bezierPath.lineWidth = 1.0
            bezierPath.appendRoundedRect(geometry.bounds,
                                         xRadius: 4, yRadius: 4)

            Colors.bubbleBackground.set()
            bezierPath.fill()

            // right now highlighting bubbles by drawing a color wash
            // over them.  So draw this over the prior background
            if isBubbleMousedOver(geometry.bubbleID) {
                Colors.bubbleMouseOver.set()
                bezierPath.fill()
            }

            let string = soup.bubbles[Int(geometry.bubbleID)].title! as NSString

//            let attributedString = NSAttributedString.init(string: string as String)
            var stringRect = geometry.bounds.insetBy(dx: 3, dy: 3)
            let height = string.heightFor(width: stringRect.width)
            stringRect.size = CGSize(width: stringRect.width, height: height)
            string.draw(with: stringRect,
                        options: .usesLineFragmentOrigin)
            
            Colors.bubbleFrame.set()
            bezierPath.stroke()
        }
    }

    override func draw(_ dirty_dirty_Rect: NSRect) {
        Colors.canvasBackground.set()
        bounds.fill()
        
        if scene != nil {
            drawConnections()
            drawBubbles()
        }

        NSColor.black.set()
        bounds.frame()
    }
}

/// Event handling
extension SceneView {
    override var acceptsFirstResponder: Bool { return true }

    // thank you peter! https://boredzo.org/blog/archives/2007-05-22/virtual-key-codes
    enum Keycodes: UInt16 {
        case spacebar = 49
        case delete = 51
    }

    enum Cursor {
        case arrow
        case openHand
        case closedHand

        var nscursor: NSCursor {
            switch self {
            case .arrow: return NSCursor.arrow
            case .openHand: return NSCursor.openHand
            case .closedHand: return NSCursor.closedHand
            }
        }
    }

    override func resetCursorRects() {
        addCursorRect(bounds, cursor: currentCursor.nscursor)
    }

    func setCursor(_ cursor: Cursor) {
        currentCursor = cursor
        cursor.nscursor.set()
        window?.invalidateCursorRects(for: self)
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == Keycodes.spacebar.rawValue {
            if !spaceDown {
                spaceDown = true
                setCursor(.openHand)
            }
        } else if event.keyCode == Keycodes.delete.rawValue {
            setCursor(.arrow)
            // todo: handle delete - issue #16
        } else {
            setCursor(.arrow)
            spaceDown = false
            // todo: handle the keypress - issue #15
        }
    }
    
    override func keyUp(with event: NSEvent) {
        if event.keyCode == Keycodes.spacebar.rawValue {
            spaceDown = false
            setCursor(.arrow)
        } else {
            // todo: handle the keyup - issue #15
        }
    }

    override func mouseDown(with event: NSEvent) {
        let locationInWindow = event.locationInWindow
        let viewLocation = convert(locationInWindow, from: nil)
        lastPoint = viewLocation

        // commit text editing if the editor is up

        if spaceDown {
            setCursor(.closedHand)
            currentMouseHandler = MouseGrabHand(withSupport: self)
            currentMouseHandler?.start(at: locationInWindow, modifierFlags: event.modifierFlags)
            return
        }

        // do other mousey things
    }

    override func mouseDragged(with event: NSEvent) {
        let locationInWindow = event.locationInWindow
        let viewLocation = convert(locationInWindow, from: nil) as CGPoint

        lastPoint = viewLocation

        if let handler = currentMouseHandler {
            if handler.prefersWindowCoordinates {
                handler.drag(to: locationInWindow, modifierFlags: event.modifierFlags)
            } else {
                handler.drag(to: viewLocation, modifierFlags: event.modifierFlags)
            }
        }
    }

    override func mouseUp(with event: NSEvent) {
        let locationInWindow = event.locationInWindow
        let viewLocation = convert(locationInWindow, from: nil) as CGPoint
        lastPoint = viewLocation

        defer {
            currentMouseHandler = defaultMouseHandler
        }

        if spaceDown {
            setCursor(.openHand)
        }

        if let handler = currentMouseHandler {
            handler.finish(at: viewLocation, modifierFlags: event.modifierFlags)
            return
        }
    }

    override func updateTrackingAreas() {
        if spaceDown { return }

        if let trackingArea = trackingArea {
            removeTrackingArea(trackingArea)
            self.trackingArea = nil
        }
        addTrackingAreas()
    }

    func addTrackingAreas() {
        let trackingArea = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .mouseMoved, .activeInKeyWindow], owner: self, userInfo: nil)
        addTrackingArea(trackingArea)
    }

    override func mouseMoved(with event: NSEvent) {
        if spaceDown { return }
        guard let handler = currentMouseHandler else { return} 

        let locationInWindow = event.locationInWindow

        if handler.prefersWindowCoordinates {
            currentMouseHandler?.move(to: locationInWindow,
                                      modifierFlags: event.modifierFlags)
        } else {
            let viewLocation = convert(locationInWindow, from: nil)
            handler.move(to: viewLocation,
                         modifierFlags: event.modifierFlags)
        }
    }
}

extension SceneView: MouseSupport {
    var currentScrollOffset: CGPoint {
        guard let clipview = superview as? NSClipView else {
            fatalError("no clip vieW?")
        }

        let origin = clipview.bounds.origin
        return origin
    }

    func scroll(to newOrigin: CGPoint) {
        scroll(newOrigin)
    }

    func hitTestBubble(at point: CGPoint) -> Bubble? {
        guard let soup else { return nil }

        for geometry in scene.geometries {
            if geometry.bounds.contains(point) {
                let bubbleID = geometry.bubbleID
                let bubble = soup.bubbles[Int(bubbleID)]
                return bubble
            }
        }
        return nil
    }

    func hoveredBubble(bubbleID: BubbleID?) {
        if let bubbleID = bubbleID {
            highlightedBubbleID = bubbleID
            needsDisplay = true
        } else {
            highlightedBubbleID = nil
            needsDisplay = true
        }
    } // hoveredBubble
}
