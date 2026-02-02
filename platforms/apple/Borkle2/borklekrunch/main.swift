// main.swift: driver for borklekrunch

import Foundation
import Yams

let args = CommandLine.arguments

// !!! have a flag for this, especially as stuff gets more fleshed out
let showWarnings = false

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
// title character range
// connection-count
// bubble1ID bubble2ID (repeated for each connection)
// geometry-count
// bubbleID bounds-x y w h (repeated for each geometry)
// string-pool length
// string-pool all the strings laid end to end.

// you can bloop the whole string pool into memory and not have to
// parse out lines and append to a pool on the destination-side

struct TextSpan {
    let start: Int
    let length: Int
}

var spans: [TextSpan] = []
var stringPool: String = ""

accumulateStrings()
emitVersion()
emitBubbles(soup)
emitConnections(scene)
emitGeometry(scene)
emitStringPool(stringPool)

func accumulateStrings() {
    // !!! figure out if there's a max on PERQ or something, and then
    // !!! (optionally) warn if we exceed it.
    let bubbles = soup.bubbles

    for bubble in bubbles {
        
        let title = bubble.title ?? ""
        let lossyAsciiData = title.data(using: .ascii, allowLossyConversion: true) ?? Data()
        let lossyTitle = String(decoding: lossyAsciiData,
                                as: Unicode.ASCII.self)
        
        // for the future, the body needs to get poold'
        let span = TextSpan(start: stringPool.count,
                            length: lossyTitle.count)
        spans.append(span)
        stringPool += lossyTitle

        if showWarnings {
            if title != lossyTitle {
                print("WARNING: ascii-downgraded string: |\(title)| -> |\(lossyTitle)")
            }
        }
    }
}

func emitVersion() {
    print("1")
}

func emitBubbles(_ soup: BubbleSoup) {
    let bubbles = soup.bubbles

    print(bubbles.count)

    for bubble in bubbles {
        let bubbleID = bubble.ID
        print("\(spans[Int(bubbleID)].start) \(spans[Int(bubbleID)].length)")
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
        print("\(geometry.bubbleID) \(Int(geometry.bounds.origin.x)) \(Int(geometry.bounds.origin.y)) \(Int(geometry.bounds.width)) \(Int(geometry.bounds.height))")
    }
}

func emitStringPool(_ stringPool: String) {
    print(stringPool.count)
    print(stringPool)
}
