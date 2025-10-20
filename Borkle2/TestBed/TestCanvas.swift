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

    func fillBackground() {
        NSColor.white.set()
        bounds.fill()
    }

    func strokeBorder() {
        NSColor.black.set()
        bounds.frame()
    }

    func drawConnections() throws {
        NSColor.purple.set()
        
         for connection in scene.connections {
             let endpoints = try scene.endpoints(for: connection)
             let g1 = try scene.geometry(for: endpoints.source)
             let g2 = try scene.geometry(for: endpoints.destination)
             let p1 = g1.bounds.center
             let p2 = g2.bounds.center

             NSBezierPath.strokeLine(from: p1, to: p2)
         }
    }

    func drawBubbles() throws {
    }
    
    override func draw(_ dirtyRect: CGRect) {
        fillBackground()

        do {
            try drawConnections()
            try drawBubbles()
        } catch {
            print("ERROR drawing: \(error)")
        }
        
        strokeBorder()
    }

    override var isFlipped: Bool { true }
}
