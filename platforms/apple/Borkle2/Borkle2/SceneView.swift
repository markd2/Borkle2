// SceneView.swift: all the heavy lifting for the mind-map user interface

import AppKit

class SceneView: NSView {
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

    var spaceDown: Bool = false
    var currentCursor: Cursor = .arrow

    /// for things like "hey paste at the last place the user clicked.
    var lastPoint: CGPoint?

    func drawConnections() {
        Colors.bubbleConnection.set()
        for connection in scene.connections {
            NSBezierPath.strokeLine(from: connection.bubble1Center,
                                    to: connection.bubble2Center)
        }
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
            currentMouseHandler = nil
        }

        if spaceDown {
            setCursor(.openHand)
        }

        if let handler = currentMouseHandler {
            handler.finish(at: viewLocation, modifierFlags: event.modifierFlags)
            return
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
}
