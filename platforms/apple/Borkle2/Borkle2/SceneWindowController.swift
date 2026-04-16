// SceneWindowController.swift: the view^H^H^H^H window controller for a scene

import AppKit
import Yams

class SceneWindowController: NSWindowController {
    @IBOutlet var sceneView: SceneView!
    @IBOutlet var scroller: NSScrollView!

    @IBOutlet var filenameLabel: NSTextField! {
        didSet {
            if filename != nil {
                filenameLabel.stringValue = "(\(filename!))"
            }
        }
    }

    var filename: String! {
        didSet {
            if filenameLabel != nil {
                filenameLabel.stringValue = "(\(filename!))"
            }
        }
    }

    var soup: BubbleSoup!
    var scene: Scene = Scene()

    override func awakeFromNib() {
        super.awakeFromNib()

        scroller.contentView.backgroundColor = Colors.canvasBackground
        scroller.hasHorizontalScroller = true
        scroller.hasVerticalScroller = true
    }

    @IBAction func splunge(_ sender: NSControl) {
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
        let place = URL(fileURLWithPath: "/Users/markd/Downloads/modcompnotes-scene.yaml")
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

    func updateZoomLabel() {
        zoomLabel.stringValue = "\(sceneView.zoomLevel)%"
    }

    @IBAction func zoomIn(_ sender: NSControl) {
        Swift.print("oop")
        let newZoom = sceneView.zoomLevel + 10
        sceneView.zoomLevel = newZoom
        updateZoomLabel()
    }

    @IBAction func zoomOut(_ sender: NSControl) {
        Swift.print("ack")
        let newZoom = max(sceneView.zoomLevel - 10, 50)
        sceneView.zoomLevel = newZoom
        updateZoomLabel()
    }
}


