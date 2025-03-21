import Foundation
import Cocoa

class Bubble : Codable {
    typealias Identifier = Int

    var ID: Identifier
    var text: String = ""

    static let defaultFontName = "Helvetica"
    static let defaultFontSize: CGFloat = 12.0

    struct FormattingStyle: OptionSet, Codable {
        let rawValue: Int
        static let bold          = FormattingStyle(rawValue: 1 << 0)
        static let italic        = FormattingStyle(rawValue: 1 << 1)
        static let strikethrough = FormattingStyle(rawValue: 1 << 2)
        static let underline     = FormattingStyle(rawValue: 1 << 3)
    }
    

    /// convert attributed string to formatting options
    func gronkulateAttributedString(_ attr: NSAttributedString) {
        formattingOptions = []

        let totalRange = NSMakeRange(0, attr.length)

        attr.enumerateAttributes(in: totalRange, options: []) { (attributes: [NSAttributedString.Key : Any], range: NSRange, stop: UnsafeMutablePointer<ObjCBool>) in
            if let font = attributes[.font] as? NSFont {
                let traits = font.fontDescriptor.symbolicTraits

                if traits.contains(.italic) && traits.contains(.bold) {
                    let foption = FormattingOption([.bold, .italic], range: range)
                    formattingOptions.append(foption)

                } else if traits.contains(.italic) {
                    let foption = FormattingOption([.italic], range: range)
                    formattingOptions.append(foption)
                    
                } else if traits.contains(.bold) {
                    let foption = FormattingOption([.bold], range: range)
                    formattingOptions.append(foption)
                }
            }
                
            if let _ = attributes[.strikethroughStyle] {
                let foption = FormattingOption([.strikethrough], range: range)
                formattingOptions.append(foption)
            }

            if let _ = attributes[.underlineStyle] {
                let foption = FormattingOption([.underline], range: range)
                formattingOptions.append(foption)
            }
        }
    }

    /// make an attributed string from the formatting option
    /// If this proves to be slow with :alot: of bubbles, then
    /// should be able to cache this.
    var attributedString: NSAttributedString {
        let string = NSMutableAttributedString(string: text)
    
        // Can these be extracted out?
        let font = NSFont(name: Bubble.defaultFontName, size: Bubble.defaultFontSize)!
        let boldDescriptor = font.fontDescriptor.withSymbolicTraits(.bold)
        let boldFont = NSFont(descriptor: boldDescriptor, size: Bubble.defaultFontSize)!
        let italicDescriptor = font.fontDescriptor.withSymbolicTraits(.italic)
        let italicFont = NSFont(descriptor: italicDescriptor, size: Bubble.defaultFontSize)!
        let boldItalicDescriptor = font.fontDescriptor.withSymbolicTraits([.italic, .bold])
        let boldItalicFont = NSFont(descriptor: boldItalicDescriptor, size: Bubble.defaultFontSize)!

        formattingOptions.forEach { option in
            if option.options.contains(.bold) && option.options.contains(.italic) {
                string.addAttribute(.font,
                                    value: boldItalicFont,
                                    range: option.nsrange)
                
            } else if option.options.contains(.bold) {
                string.addAttribute(.font,
                                    value: boldFont,
                                    range: option.nsrange)
                
            } else if option.options.contains(.italic) {
                string.addAttribute(.font,
                                    value: italicFont,
                                    range: option.nsrange)
                
            }
            if option.options.contains(.strikethrough) {
                string.addAttribute(.strikethroughStyle,
                                    value: NSUnderlineStyle.single.rawValue,
                                    range: option.nsrange)
            }
            if option.options.contains(.underline) {
                string.addAttribute(.underlineStyle,
                                    value: NSUnderlineStyle.single.rawValue,
                                    range: option.nsrange)
            }
        }
        return string
    }

    struct FormattingOption: Codable, Equatable {
        let options: FormattingStyle
        let rangeStart: Int 
        let rangeLength: Int 

        var nsrange: NSRange {
            NSRange(location: rangeStart, length: rangeLength)
        }
        
        init(options: FormattingStyle, rangeStart: Int, rangeLength: Int) {
            self.options = options
            self.rangeStart = rangeStart
            self.rangeLength = rangeLength
        }

        // concise version for tests.
        init(_ options: FormattingStyle, _ rangeStart: Int, _ rangeLength: Int) {
            self.options = options
            self.rangeStart = rangeStart
            self.rangeLength = rangeLength
        }

        init(_ options: FormattingStyle, range: NSRange) {
            self.options = options
            self.rangeStart = range.location
            self.rangeLength = range.length
        }
    }

    var formattingOptions: [FormattingOption] = []

    init(ID: Int) {
        self.ID = ID
    }
}


extension Bubble: CustomDebugStringConvertible {
    var debugDescription: String {
        return "Bubble(ID: \(ID), text: '\(text)')"
    }
}


