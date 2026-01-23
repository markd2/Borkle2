// DocumentWindowController: window controller for the main document

import AppKit
import Yams

class DocumentWindowController: NSWindowController {

    @IBOutlet var bubbleTableView: NSTableView!
    @IBOutlet var tagTableView: NSTableView!

    @IBOutlet var titleField: NSTextField!
    @IBOutlet var bodyField: NSTextField!
    @IBOutlet var tagsField: NSTextField!

    @IBOutlet var searchField: NSSearchField!

    // use a temporary to initialize, and actually assign in awakeFromNib
    var soupAspect: SoupAspect = SoupAspect(BubbleSoup())
   
    override func windowDidLoad() {
        super.windowDidLoad()
        window?.makeKeyAndOrderFront(nil)
    }

    /// Looks like the new 'improved' view-based tableview can trigger
    /// awakeFromNib multiple times, one extra time for each tableview row
    /// visible.  If you're doing one-time stuff in awakeFromNib, that's
    /// kind of a problem. So hack around it by only running the one-time
    /// work once.
    var alreadyAwokenFromNib = false

    var soup: BubbleSoup {
        (document as! Document).soup
    }

    override func awakeFromNib() {
        if !alreadyAwokenFromNib {
            let cellNib = NSNib(nibNamed: "BubbleTableViewCell", bundle: nil)
            bubbleTableView.register(cellNib, forIdentifier: NSUserInterfaceItemIdentifier("bubbleColumn"))
            setupObservers()

            soupAspect = SoupAspect(soup)
            
            alreadyAwokenFromNib = true
        }
    }

    func setupObservers() {
        NotificationCenter.default.addObserver(
          self,
          selector: #selector(windowDidResize),
          name: NSWindow.didResizeNotification,
          object: window
        )
    }

    @objc func windowDidResize(_ notification: Notification) {
        bubbleTableView.reloadData()
    }

    @IBAction func splunge(_ sender: NSControl) {
        
        let bubbles =
          [
            Bubble(title: "Spoon", body: "Once upon a midnight dreary etc etc etc", tags: ["first", "splunge"], asset: nil),
            Bubble(title: "Greeble Bork", body: "blah blah blah blah blah blah blah", tags: [], asset: nil),
            Bubble(title: "Hoover fnord ekky", body: "Folks who are even a tiny bit crafty know the name Singer.  Back in the day, they had a nationwide chain of 175 stores selling the machines, fabrics, patterns, and associated goodies.  They needed automation", tags: ["singer", "system-ten", "exhibit"], asset: nil),
          ]

        soup.bubbles = bubbles
        soupAspect = SoupAspect(soup)

        bubbleTableView.reloadData()
        tagTableView.reloadData()
    }

    @IBAction func saveYaml(_ sender: NSControl) {
        Swift.print("SAVE")
        let encoder = YAMLEncoder()
        var options = encoder.options
        options.indent = 2
        options.width = -1
        options.explicitStart = true
        options.explicitEnd = true
        options.sortKeys = true
        encoder.options = options
        let encodedYAML = try! encoder.encode(soup)
        let data = encodedYAML.data(using: .utf8)!
        let place = URL(fileURLWithPath: "/Users/markd/Downloads/blargh.yaml")
        try! data.write(to: place)
    }
 
    @IBAction func loadYaml(_ sender: NSControl) {
        Swift.print("LOAD")
        let place = URL(fileURLWithPath: "/Users/markd/Downloads/blargh.yaml")
        let data = try! Data(contentsOf: place, options: [])
        let decoder = YAMLDecoder()
        let decoded = try! decoder.decode(BubbleSoup.self, from: data)
        (document as! Document).soup = decoded

        soupAspect = SoupAspect(soup)
        bubbleTableView.reloadData()
        tagTableView.reloadData()
        
        Swift.print(soup)
    }

    @IBAction func verify(_ sender: NSControl) {
        soup.verify()
    }

    @IBAction func addItem(_ sender: NSControl) {
        let title = titleField.stringValue
        let body = bodyField.stringValue
        let tags = tagsField.stringValue.components(separatedBy: " ")

        let bubble = Bubble(title: title, body: body, tags: tags, asset: nil)
        soup.addBubble(bubble)

        titleField.stringValue = ""
        bodyField.stringValue = ""
        tagsField.stringValue = ""

        bubbleTableView.reloadData()
        tagTableView.reloadData()
    }
}

extension DocumentWindowController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView == bubbleTableView {
            return bubbleViewCount()
        }

        if tableView == tagTableView {
            return soup.allTags.count
        }

        return 0
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if tableView == bubbleTableView {
            return bubbleHeightOfRow(row)
        }

        if tableView == tagTableView {
            return 20
        }

        return 0
    }

    func tableView(_ tableView: NSTableView,
                   viewFor tableColumn: NSTableColumn?,
                   row: Int) -> NSView? {
        guard tableColumn != nil else {
            Swift.print("nil column")
            return nil
        }

        if tableView == bubbleTableView {
            return bubbleViewFor(tableColumn, row)
        }

        if tableView == tagTableView {
            return tagViewFor(tableColumn, row)
        }

        return nil
    }

    func bubbleViewCount() -> Int {
        soupAspect.indices.count
    }

    func bubbleHeightOfRow(_ row: Int) -> CGFloat {
        let bubble = soup.bubbles[soupAspect.indices[row]]
        let bodyHeight = heightFor(bubble.body, width: bubbleTableView.bounds.width)
        let totalHeight = bodyHeight + 40
        return totalHeight
    }

    func tagViewFor(_ column: NSTableColumn?, _ row: Int) -> NSView? {
        guard let column else { return nil }

        let tags = soup.allTags

        let cell = tagTableView.makeView(
          withIdentifier: column.identifier,
          owner: self
        ) as? NSTableCellView
        
        cell?.textField?.stringValue = tags[row]

        return cell
    }
    
    func bubbleViewFor(_ column: NSTableColumn?, _ row: Int) -> NSView? {
        guard let column else { return nil }
        
        let bubble = soup.bubbles[soupAspect.indices[row]]

        switch column.identifier.rawValue {
        case "bubbleColumn":
            let cell = bubbleTableView.makeView(
                withIdentifier: column.identifier,
                owner: self
            ) as? BubbleTableViewCell
            
            cell?.titleField?.stringValue = "\(row)) " + (bubble.title ?? "----")
            cell?.bodyField?.stringValue = bubble.body ?? "----"
            cell?.tagsField?.stringValue = bubble.tags?.joined(separator: ", ") ?? "----"
            cell?.backgroundColor = row.isMultiple(of: 2) ? Colors.bubbleListCellBackground_Even : Colors.bubbleListCellBackground_Odd
            return cell
            
        default:
            Swift.print("huh, identifier \(column.identifier)")
            return nil
        }
    }
}

extension DocumentWindowController: NSSearchFieldDelegate {
    func searchFieldDidStartSearching(_ searchField: NSSearchField) {
    }

    func searchFieldDidEndSearching(_ searchField: NSSearchField) {
        soupAspect.predicate = SoupAspect.identity
    }

    // Thought I would use searchFieldDidStart/EndSearching, but there's a weird timeout,
    // so I can type a bunch of stuff, get a bunch of these callbacks, and *then* get the
    // didStartSearching. Given how terrible the iOS SearchField class is, I'm not too sanguine
    // on how much of the search field's specific features outside of this I'll use.
    func controlTextDidChange(_ notification: Notification) {
        defer {
            bubbleTableView.reloadData()
        }

        guard self.searchField.stringValue.count > 0 else {
            soupAspect.predicate = SoupAspect.identity
            return
        }
        soupAspect.predicate = { bubble in 
            bubble.containsString(self.searchField.stringValue)
        }
    }
}

extension DocumentWindowController {
    func heightFor(_ text: String?, width: CGFloat) -> CGFloat {
        guard let text else { return 0 }

        let textStorage = NSTextStorage.init(string: text, attributes: nil)
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
