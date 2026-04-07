// StringUtilties - utility things with strings

import AppKit

extension NSString {

    // given some text, and a width to wrap in to, wrap it.
    // Using default font, etc.
    func heightFor(width: CGFloat) -> CGFloat {
        let textStorage = NSTextStorage.init(string: self as String, attributes: nil)
        let margin: CGFloat = 5
        let insetWidth = width - (margin * 2)
        let size = CGSize(width: insetWidth, height: .infinity)
        let textContainer = NSTextContainer.init(containerSize: size)
        let layoutManager = NSLayoutManager()

        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // maybe need to add the font attribute textStorage.add
        textContainer.lineFragmentPadding = 0.0
        
        _ = layoutManager.glyphRange(for: textContainer)
        let height = layoutManager.usedRect(for: textContainer).height
        return height
    }
}
