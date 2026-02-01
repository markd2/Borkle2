// main.swift: driver for borklekrunch

import Foundation
import Yams

let args = CommandLine.arguments

// expecting two arguments
guard args.count == 2 else {
    print("Usage: \(args[0]) input-basename")
    print("    uses input-basename to derive bubble and a scene file name, then")
    print("    writes to stdout an ascii output file suitable (hopefully) for older")
    print("    systems")
    exit(1)
}

// load the bubbles and scene

let bubblePath = "\(args[1])-bubbles.yaml"
let scenePath = "\(args[1])-scene.yaml"
let decoder = YAMLDecoder()

let soupData = try! Data(contentsOf: URL(fileURLWithPath: bubblePath), options: [])
let soup = try! decoder.decode(BubbleSoup.self, from: soupData)

let sceneData = try! Data(contentsOf: URL(fileURLWithPath: scenePath), options: [])
let scene = try! decoder.decode(Scene.self, from: sceneData)

// exhale in the exchange format, which is
// 1
// bubble-count
// title (one line - we don't have any bodies or tags yet in the sample docs)
// connection-count
// bubble1ID bubble2ID (repeated for each connection)
// geometry-count
// bubbleID
// bounds x y w h

emitVersion()
emitBubbles(soup)
emitConnections(scene)
emitGeometry(scene)
emitTrailer()

func emitVersion() {
    print("1")
}

func flattenNewlines(_ string: String) -> String {
    string.replacingOccurrences(of: "\n", with: "<NL>")
}

func emitBubbles(_ soup: BubbleSoup) {
    let bubbles = soup.bubbles

    print(bubbles.count)

    for bubble in bubbles {
        print(flattenNewlines(bubble.title ?? ""))
    }
}

func emitConnections(_ scene: Scene) {
    let connections = scene.connections
    print(connections.count)
    
    for connection in connections {
        print("\(connection.bubble1ID) \(connection.bubble2ID)")
    }
}

func emitGeometry(_ scene: Scene) {
    let geometries = scene.geometries
    for geometry in geometries {
        print(geometry.bubbleID)
        print("\(Int(geometry.bounds.origin.x)) \(Int(geometry.bounds.origin.y)) \(Int(geometry.bounds.width)) \(Int(geometry.bounds.height))")
    }
}

func emitTrailer() {
    print("bork")
}
