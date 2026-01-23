// BubbleTableViewCell: bootstrapping getting list of cells visible

import AppKit

class BubbleTableViewCell: NSTableCellView {
    @IBOutlet var titleField: NSTextField!
    @IBOutlet var bodyField: NSTextField!
    @IBOutlet var tagsField: NSTextField!

    override var backgroundStyle: NSView.BackgroundStyle {
        get {
            .emphasized
        }
        set { 
            // nom
        }
    }

    var backgroundColor: NSColor {
        get {
            if let layerbg = layer?.backgroundColor {
                return NSColor(cgColor: layerbg) ?? NSColor.white
            } else {
                return NSColor.white
            }
        }

        set(newColor) {
            layer?.backgroundColor = newColor.cgColor
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        wantsLayer = true
    }
}

