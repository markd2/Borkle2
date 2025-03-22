import Foundation

class Connection : Codable {
    var start: Bubble.Identifier
    var end: Bubble.Identifier
    var label: String = ""
    // connection style - e.g. arrows or not
}

class BubbleLocation: Codable {
    var bubbleID: Bubble.Identifier
    var frame: CGRect
    var fillColor: RGB = RGB.white
    // border style. stroke color
}

class Barrier: Codable {
    var vertical = true
    var location: NSInteger
}

// ----------

class Frame: Codable {
    var bubbleIDs: [Bubble.Identifier] = []
    var locations: [BubbleLocation] = []
    var connections: [Connection] = []

    var barriers: [Barrier] = []
}
