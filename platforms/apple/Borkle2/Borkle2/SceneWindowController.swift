// SceneWindowController.swift: the view^H^H^H^H window controller for a scene

import AppKit

class SceneWindowController: NSWindowController {
    @IBOutlet var sceneView: SceneView!

    var scene: Scene = Scene()

    @IBAction func splunge(_ sender: NSControl) {
        Swift.print("ook")
    }
}


