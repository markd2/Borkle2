// main.swift: borkle1-conv's driver program

import Foundation
import Yams

let args = CommandLine.arguments

// expecting two arguments
guard args.count == 3 else {
    print("Usage: \(args[0]) file.borkle output-basename")
    exit(1)
}

let inputURL = URL(fileURLWithPath: args[1])
let outputURL = URL(fileURLWithPath: args[2])

// inputURL is a borkle document, which is a packge that has a
// pair of yaml files, one for bubbles/soup, one for barriers.

let inputYAMLURL = inputURL.appendingPathComponent("bubbles.yaml")
let data = try! Data(contentsOf: inputYAMLURL, options: [])
let decoder = YAMLDecoder()
let oldBubbles = try! decoder.decode([B1Bubble].self, from: data)






