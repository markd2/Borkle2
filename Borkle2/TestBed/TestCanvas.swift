// Copyright 2025 Borkware.

import AppKit

class TestCanvas: NSView {
    var bubbles: BubbleSoup
    var scene: Scene

    override init(frame: CGRect) {
        fatalError("currently not making this outside of a xib")
    }
    
    required init?(coder: NSCoder) {
        bubbles = BubbleSoup()
        scene = Scene(soup: bubbles)
        super.init(coder: coder)

        setupSampleScene()
    }

    func setupSampleScene() {
        let b1 = bubbles.newBubble()
        let b2 = bubbles.newBubble()

        scene.add(bubble: b1)
        scene.add(bubble: b2)

        scene.add(connectionFrom: b1, to: b2)

    }
    
    override func draw(_ dirtyRect: CGRect) {
        NSColor.white.set()
        bounds.fill()
        
        NSColor.black.set()
        bounds.frame()
    }

}
