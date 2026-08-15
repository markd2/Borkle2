// SceneWindowController.swift: the view^H^H^H^H window controller for a scene

import AppKit
import Yams

class SceneWindowController: NSWindowController {
    @IBOutlet var sceneView: SceneView!
    @IBOutlet var scroller: NSScrollView!
    @IBOutlet var findSearchField: NSSearchField!

    @IBOutlet var filenameLabel: NSTextField! {
        didSet {
            if filename != nil {
                filenameLabel.stringValue = "(\(filename!))"
            }
        }
    }

    @IBOutlet var searchResultLabel: NSTextField!

    var filename: String! {
        didSet {
            if filenameLabel != nil {
                filenameLabel.stringValue = "(\(filename!))"
            }
        }
    }

    var soup: BubbleSoup!
    var scene: Scene = Scene()
    var searchResults: [SearchResult]? {
        didSet {
            sceneView.searchResults = searchResults
            currentSearchIndex = -1
        }
    }
    var currentSearchIndex = -1 {
        didSet {
            updateSearchText()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        scroller.contentView.backgroundColor = Colors.canvasBackground
        scroller.hasHorizontalScroller = true
        scroller.hasVerticalScroller = true
    }

    // add tag rects
    @IBAction func splunge(_ sender: NSControl) {
        let tagHeight = 18.0

        for (i, geometry) in scene.geometries.enumerated() {
            let bubble = soup.bubbles[geometry.bubbleID]
            guard let tags = bubble.tags, !tags.isEmpty else { continue }

            // if we have tags, add a tag rect at the bottom
            var tagsRect = geometry.totalBounds
            tagsRect.origin.y = tagsRect.minY + tagsRect.height
            tagsRect.size.height = tagHeight
            
            let replacementGeometry = BubbleGeometry(
              bubbleID: geometry.bubbleID,
              bodyRect: geometry.bodyRect,
              titleRect: geometry.titleRect,
              tagsRect: tagsRect)
            
            scene.geometries[i] = replacementGeometry
        }
        sceneView.needsDisplay = true
        updateScrollJunk()
    }

    // Add title rects to the thingies that have titles
    @IBAction func splungeEmbigginTitle(_ sender: NSControl) {
        let additionalTitleHeight = 6.0

        for (i, geometry) in scene.geometries.enumerated() {
            let bubble = soup.bubbles[geometry.bubbleID]
            guard bubble.title != nil else { continue }

            // if we have a title, embiggen the title rect at the top
            guard var titleRect = geometry.titleRect else { continue }
            titleRect.size.height = titleRect.size.height + additionalTitleHeight
            
            // scoot the body down
            guard var bodyRect = geometry.bodyRect else { continue }
            bodyRect.origin.y = bodyRect.origin.y + additionalTitleHeight
            
            let replacementGeometry = BubbleGeometry(
              bubbleID: geometry.bubbleID,
              bodyRect: bodyRect,
              titleRect: titleRect)
            
            scene.geometries[i] = replacementGeometry
        }
        sceneView.needsDisplay = true
        updateScrollJunk()
    }

    @IBAction func splungeXXX(_ sender: NSControl) {
        _ = scene.addID(1)
        _ = scene.addID(2)
        _ = scene.addID(3)
        _ = scene.addID(4)
        _ = scene.addID(5)

        let centerCenter = CGPoint(x: 275, y: 200)
        let size = CGSize(width: 120, height: 50)
        let centerRect = CGRect.centered(at: centerCenter, size: size)

        _ = scene.changeGeometry(for: 5,
                                 to: centerRect)

        _ = scene.changeGeometry(for: 1,
                                 to: centerRect.offsetBy(dx: -100 - size.width / 2, dy: 0))
        _ = scene.changeGeometry(for: 2,
                                 to: centerRect.offsetBy(dx: 150, dy: 0))

        _ = scene.changeGeometry(for: 3,
                                 to: centerRect.offsetBy(dx: 0, dy: -100))
        _ = scene.changeGeometry(for: 4,
                                 to: centerRect.offsetBy(dx: 0, dy: 100))

        _ = scene.addConnection(from: 1, to: 5)
        _ = scene.addConnection(from: 2, to: 5)
        _ = scene.addConnection(from: 3, to: 5)
        _ = scene.addConnection(from: 4, to: 5)
        _ = scene.addConnection(from: 5, to: 5)

        sceneView.scene = scene
        sceneView.soup = soup

        updateScrollJunk()
    }

    @IBAction func save(_ sender: NSControl) {
        guard scene.bubbleIDs.count > 0 else {
            Swift.print("cowardly refusing to save if there's no bubbles in this scene")
            return
        }
        
        Swift.print("SAVE SCENE")
        let encoder = YAMLEncoder()
        var options = encoder.options
        options.indent = 2
        options.width = -1
        options.explicitStart = true
        options.explicitEnd = true
        options.sortKeys = true
        encoder.options = options
        let encodedYAML = try! encoder.encode(scene)
        let data = encodedYAML.data(using: .utf8)!
        let place = URL(fileURLWithPath: "/Users/markd/Downloads/\(filename!).yaml")
        try! data.write(to: place)
    }

    func actuallyLoadYaml() {
//        let place = URL(fileURLWithPath: "/Users/markd/Downloads/\(filename!).yaml")
//        let place = URL(fileURLWithPath: "/Users/markd/Downloads/modcompnotes-scene.yaml")
        let place = Bundle.main.url(forResource: "modcompnotes-scene", withExtension: "yaml")!
        let data = try! Data(contentsOf: place, options: [])
        let decoder = YAMLDecoder()
        let decoded = try! decoder.decode(Scene.self, from: data)
        scene = decoded
        
        sceneView.scene = scene
        sceneView.soup = soup

        updateScrollJunk()
    }

    @IBAction func load(_ sender: NSControl) {
        actuallyLoadYaml()
    }

    func updateScrollJunk() {
        let snuggly = scene.snugglyRect
        Swift.print("SNUGGLI \(snuggly)")
        sceneView.frame = snuggly
    }

    @IBOutlet var zoomLabel: NSTextField!

    var zoomLevel: Int = 100

    func updateZoom() {
        zoomLabel.stringValue = "\(zoomLevel)%"
        scroller.magnification = CGFloat(zoomLevel) / 100.0
    }

    @IBAction func zoomIn(_ sender: NSControl) {
        Swift.print("oop")
        zoomLevel += 10
        updateZoom()
    }

    @IBAction func zoomOut(_ sender: NSControl) {
        Swift.print("ack")
        zoomLevel = max(zoomLevel - 10, 30)
        updateZoom()
    }

    func updateSearchText() {
        var text = ""

        if searchResults == nil {
        } else if currentSearchIndex < 0 {
            text = "\(searchResults?.count ?? 0) found"
        } else {
            text = "\(currentSearchIndex + 1) / \(searchResults?.count ?? 0)"
        }
        searchResultLabel.stringValue = text
    }

    func handleSearchMovement(backwards: Bool) {
        let count = searchResults?.count ?? 0
        guard count > 0 else { return }

        if backwards {
            currentSearchIndex -= 1
            if currentSearchIndex < 0 { currentSearchIndex = 0 }
        } else {
            currentSearchIndex += 1
            if currentSearchIndex > count {
                currentSearchIndex = count - 1
            }
        }

        if currentSearchIndex < count {
            sceneView.moveSearchResultTo(searchIndex: currentSearchIndex)
        }
    }
}



extension SceneWindowController: NSSearchFieldDelegate {

    func control(_ control: NSControl, textView: NSTextView,
                 doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(NSResponder.insertNewline(_:)) {
            var isShifty = false
            if let currentEvent = NSApp.currentEvent {
                isShifty = currentEvent.modifierFlags.contains(.shift)
            }
            handleSearchMovement(backwards: isShifty)
        }
        return false
    }

    func updateSearch() {
        let searchString = findSearchField.stringValue
        var searchResults: [SearchResult]?

        defer {
            self.searchResults = searchResults
        }

        searchResults = soup.search(for: searchString,
                                    limitBy: scene.bubbleIDs)
    }

    func searchFieldDidStartSearching(_ searchField: NSSearchField) {
    }

    func searchFieldDidEndSearching(_ searchField: NSSearchField) {
        updateSearch()
    }

    // Thought I would use searchFieldDidStart/EndSearching, but
    // there's a weird timeout, so I can type a bunch of stuff, get a
    // bunch of these callbacks, and *then* get the
    // didStartSearching. Given how terrible the iOS SearchField class
    // is, I'm not too sanguine on how much of the search field's
    // specific features outside of this I'll use.
    func controlTextDidChange(_ notification: Notification) {
        updateSearch()
    }
}

