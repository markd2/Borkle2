// Copyright 2025 Borkware.

import AppKit

class TestCanvas: NSView {
    override func draw(_ dirtyRect: CGRect) {
        NSColor.white.set()
        bounds.fill()
        
        NSColor.black.set()
        bounds.frame()
    }
}
