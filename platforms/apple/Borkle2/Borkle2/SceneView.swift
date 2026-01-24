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
        NSColor.purple.set()
        for connection in scene.connections {
            NSBezierPath.strokeLine(from: connection.bubble1Center,
                                    to: connection.bubble2Center)
        }
    }

    func drawBubbles() {
        NSColor.brown.set()
        for geometry in scene.geometries {
            geometry.bounds.frame()
        }
    }

    override func draw(_ dirty_dirty_Rect: NSRect) {
        NSColor.white.set()
        bounds.fill()
        
        if scene != nil {
            drawConnections()
            drawBubbles()
        }

        NSColor.black.set()
        bounds.frame()
    }
}
