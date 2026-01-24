// SceneWindowController.swift: the view^H^H^H^H window controller for a scene

import AppKit
import Yams

class SceneWindowController: NSWindowController {
    @IBOutlet var sceneView: SceneView!
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

    @IBAction func splunge(_ sender: NSControl) {
        _ = scene.addID(0)
        _ = scene.addID(1)
        _ = scene.addID(4)

        _ = scene.changeGeometry(for: 0,
                                 to: CGRect(x: 10, y: 10, width: 120, height: 50))
        _ = scene.changeGeometry(for: 1,
                                 to: CGRect(x: 240, y: 100, width: 90, height: 90))
        _ = scene.changeGeometry(for: 4,
                                 to: CGRect(x: 50, y: 200, width: 100, height: 40))

        _ = scene.addConnection(from: 0, to: 4)
        _ = scene.addConnection(from: 4, to: 1)

        sceneView.scene = scene
        sceneView.soup = soup
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
        let place = URL(fileURLWithPath: "/Users/markd/Downloads/\(filename!).yaml")
        let data = try! Data(contentsOf: place, options: [])
        let decoder = YAMLDecoder()
        let decoded = try! decoder.decode(Scene.self, from: data)
        scene = decoded
        
        sceneView.scene = scene
        sceneView.soup = soup
    }

    @IBAction func load(_ sender: NSControl) {
        actuallyLoadYaml()
    }
}


