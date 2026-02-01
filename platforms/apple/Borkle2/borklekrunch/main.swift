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

