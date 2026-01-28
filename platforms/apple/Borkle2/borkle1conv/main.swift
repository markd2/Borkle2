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

// inputURL is a borkle document, which is a packge that has a
// pair of yaml files, one for bubbles/soup, one for barriers.

let inputYAMLURL = inputURL.appendingPathComponent("bubbles.yaml")
let data = try! Data(contentsOf: inputYAMLURL, options: [])
let decoder = YAMLDecoder()
let oldBubbles = try! decoder.decode([B1Bubble].self, from: data)

// migrate bubbles

var soup = BubbleSoup()
var IDMap: [Int: Int32] = [:]

// first populate all the bubbles, keeping a list of old IDs to new IDs
for oldBubble in oldBubbles {
    let newBubble = Bubble(title: oldBubble.text,
                           body: nil, tags: nil, asset: nil)
    let id = soup.addBubble(newBubble)
    IDMap[oldBubble.ID] = id
}

// save it

let destinationPath = "\(args[2])-bubbles.yaml"
print(destinationPath)

let encoder = YAMLEncoder()
var options = encoder.options
options.indent = 2
options.width = -1
options.explicitStart = true
options.explicitEnd = true
options.sortKeys = true
encoder.options = options
let encodedYAML = try! encoder.encode(soup)
let outputData = encodedYAML.data(using: .utf8)!
let place = URL(fileURLWithPath: destinationPath)
try! outputData.write(to: place)


// now walk the bubbles and create the connections and geometries

var scene = Scene()

let oldSoup = B1BubbleSoup()
oldSoup.add(bubbles: oldBubbles)

for oldBubble in oldBubbles {
    let newBubbleID = IDMap[oldBubble.ID]!

    // hook up connections
    oldBubble.forEachConnection { index in
        if let otherBubble = oldSoup.bubble(byID: index) {
            let connectingID = IDMap[otherBubble.ID]!
            _ = scene.addConnection(from: newBubbleID, to: connectingID)
        }
    }

    _ = scene.changeGeometry(for: newBubbleID, to: oldBubble.rect)
}


let destinationScenePath = "\(args[2])-scene.yaml"
let encodedScene = try! encoder.encode(scene)
let outputSceneData = encodedScene.data(using: .utf8)!
let sceneplace = URL(fileURLWithPath: destinationScenePath)
try! outputSceneData.write(to: sceneplace)
