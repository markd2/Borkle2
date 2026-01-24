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

    override func draw(_ dirty_dirty_Rect: NSRect) {
        NSColor.white.set()
        bounds.fill()

        if let scene {
            NSColor.brown.set()
            for geometry in scene.geometry {
                geometry.bounds.frame()
            }
        }

        NSColor.black.set()
        bounds.frame()
    }
}
