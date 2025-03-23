import Foundation
import AppKit

class FrameView: NSView {

    override func draw(_ rect: CGRect) {
        NSColor.white.set()
        self.bounds.fill()
        NSColor.black.set()
        self.bounds.frame()
    }

}

