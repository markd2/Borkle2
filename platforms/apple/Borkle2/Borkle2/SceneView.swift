// SceneView.swift: all the heavy lifting for the mind-map user interface

import AppKit

class SceneView: NSView {
    var lastMoved = Date()

    // eventually might want a scene stack, if scenes can reference other
    // scenes as bubbles
    var scene: Scene! {
        didSet { needsDisplay = true }
    }
    var soup: BubbleSoup!
    var searchResults: [SearchResult]? {
        didSet {
            needsDisplay = true
        }
    }
    var currentSearchResult = 0

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

    // TODO: wondering if we can move the knowledge of these outside of
    // SceneView.
    var clipview: NSClipView {
        guard let cv = superview as? NSClipView else {
            fatalError("no clip view")
        }
        return cv
    }

    var scrollview: NSScrollView {
        guard let sv = clipview.superview as? NSScrollView else {
            fatalError("no scroll view")
        }
        return sv
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

    func markupForSearch(bubbleID: BubbleID,
                         attributedString attr: AttributedString,
                         searchResults: [SearchResult]?) -> AttributedString {
        let string = NSMutableAttributedString(attr)

        // !!! too much work being done
        for (i, result) in (searchResults ?? []).enumerated() {
            var foundRange: NSRange?

            switch result {
                // !!! once we get body and tag drawing support, 
                // !!! can use the .range computed property for all result
                // !!! enum cases
            case let .titleRange(ID, range):
                foundRange = (ID == bubbleID) ? range : nil
            case let .bodyRange(ID, range):
                foundRange = (ID == bubbleID) ? range : nil

            default:
                continue
            }

            guard let foundRange else { continue }

            // was going to use AttributedString, but Range and NSRange aren't
            // that miscible

            let attributes: [NSAttributedString.Key: Any]

            if i == currentSearchResult {
                attributes = [
                  .foregroundColor: NSColor.white,
                  .backgroundColor: NSColor.black
                ]
            } else {
                attributes = [
                  .foregroundColor: NSColor.orange
                ]
            }
            string.addAttributes(attributes, range: foundRange)
        }
        return AttributedString(string)
    }

    func draw(_ bubble: Bubble,
              with geometry: BubbleGeometry,
              drawHighlighted: Bool) {
        func drawBackground() {
            let bezierPath = NSBezierPath()            
            
            bezierPath.appendRoundedRect(geometry.totalBounds,
                                         xRadius: 4, yRadius: 4)
            
            Colors.bubbleBackground.set()
            bezierPath.fill()
            
            if drawHighlighted {
                Colors.bubbleMouseOver.set()
                bezierPath.fill()
            }
        }

        func drawOutline() {
            let bezierPath = NSBezierPath()
            bezierPath.lineWidth = 1.0

            bezierPath.appendRoundedRect(geometry.totalBounds,
                                         xRadius: 4, yRadius: 4)
            
            Colors.bubbleFrame.set()
            bezierPath.stroke()
        }

        func drawTitle() {
            guard let titleRect = geometry.titleRect else { return }
            let bubble = soup.bubbles[geometry.bubbleID]
            guard let title = bubble.title else {
                print("huh, we have a title but no where to draw it")
                return
            }

            // !!! duped from below and tweaked
            let bubbleString = title

            let bubbleAttributedString = AttributedString(bubbleString)
            let titleResults = searchResults?.filter { result in
                switch result {
                    case .titleRange: return true
                    default: return false
                }
            }
            let string = markupForSearch(bubbleID: geometry.bubbleID,
                                         attributedString: bubbleAttributedString,
                                         searchResults: titleResults)

            var stringRect = titleRect.insetBy(dx: 3, dy: 3)
            let height = string.heightFor(width: stringRect.width)
            stringRect.size = CGSize(width: stringRect.width, height: height)

            let nsattr = NSAttributedString(string)
            nsattr.draw(with: stringRect,
                        options: .usesLineFragmentOrigin)
            let y = titleRect.maxY
            let x = titleRect.minX
            NSColor.darkGray.set()
            NSBezierPath.strokeLine(from: CGPoint(x: x, y: y),
                                    to: CGPoint(x: x + titleRect.width,
                                                y: y))
        }

        func drawBody() {
            guard let bodyRect = geometry.bodyRect else { return }
            let bubble = soup.bubbles[geometry.bubbleID]
            guard let body = bubble.body else {
                print("huh, we have a body but no where to draw it")
                return
            }

            let bubbleString = body

            let bubbleAttributedString = AttributedString(bubbleString)
            let bodyResults = searchResults?.filter { result in
                switch result {
                    case .bodyRange: return true
                    default: return false
                }
            }
            let string = markupForSearch(bubbleID: geometry.bubbleID,
                                         attributedString: bubbleAttributedString,
                                         searchResults: bodyResults)

            var stringRect = bodyRect.insetBy(dx: 3, dy: 3)
            let height = string.heightFor(width: stringRect.width)
            stringRect.size = CGSize(width: stringRect.width, height: height)

            let nsattr = NSAttributedString(string)
            nsattr.draw(with: stringRect,
                        options: .usesLineFragmentOrigin)
        }

        let bubble = soup.bubbles[geometry.bubbleID]

        drawBackground()
        drawTitle()
        drawBody()
        drawOutline()

    }

    func drawBubbles() {
        NSColor.brown.set()
        for geometry in scene.geometries {
            let bubble = soup.bubbles[geometry.bubbleID]
            draw(bubble,
                 with: geometry,
                 drawHighlighted: isBubbleMousedOver(geometry.bubbleID))
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

    func centerOn(rect: CGRect) {
        let targetOrigin = NSPoint(
          x: rect.midX - (clipview.bounds.width / 2.0),
          y: rect.midY - (clipview.bounds.height / 2.0))
        
        let proposedRect = NSRect(origin: targetOrigin,
                              size: clipview.bounds.size)
        let constrainedRect = clipview.constrainBoundsRect(proposedRect)

        // scroll
        clipview.scroll(to: constrainedRect.origin)
        scrollview.reflectScrolledClipView(clipview) // update scrool bars
    }

    func scrollToBubble(bubbleID: BubbleID) {
        guard let geometry = scene.geometryFor(bubbleID) else { return }

        centerOn(rect: geometry.totalBounds)
    }

    func moveSearchResultTo(searchIndex: Int) {
        guard let searchResults else { return }
        assert(searchIndex >= 0 && searchIndex < searchResults.count)

        scrollToBubble(bubbleID: searchResults[searchIndex].bubbleID)
        currentSearchResult = searchIndex

        needsDisplay = true
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
        self.window?.makeFirstResponder(self)

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
        let origin = clipview.bounds.origin
        return origin
    }

    func scroll(to newOrigin: CGPoint) {
        scroll(newOrigin)
    }

    func hitTestBubble(at point: CGPoint) -> Bubble? {
        guard let soup else { return nil }

        for geometry in scene.geometries {
            if geometry.totalBounds.contains(point) {
                let bubbleID = geometry.bubbleID
                let bubble = soup.bubbles[bubbleID]
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
