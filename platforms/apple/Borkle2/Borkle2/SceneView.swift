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
