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

        let r1 = CGRect(x: 10, y: 10, width: 200, height: 100)
        let r2 = CGRect(x: 300, y: 45, width: 150, height: 150)

        scene.set(rect: r1, for: b1)
        scene.set(rect: r2, for: b2)
    }
    
    override func draw(_ dirtyRect: CGRect) {
        NSColor.white.set()
        bounds.fill()
        
        NSColor.black.set()
        bounds.frame()
    }

}
