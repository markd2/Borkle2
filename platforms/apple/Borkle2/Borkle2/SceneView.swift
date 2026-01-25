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
            Colors.bubbleBackground.set()
            geometry.bounds.fill()

            let string = soup.bubbles[Int(geometry.bubbleID)].title! as NSString
            let size = string.size()
            let stringRect = geometry.bounds.sizeCenteredIn(size)

            string.draw(with: stringRect,
                        options: .usesLineFragmentOrigin)
            
            Colors.bubbleFrame.set()
            geometry.bounds.frame()
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
