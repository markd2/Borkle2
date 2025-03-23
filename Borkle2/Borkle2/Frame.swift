import Foundation

class Connection : Codable {
    var start: Bubble.Identifier
    var end: Bubble.Identifier
    var label: String = ""
    // connection style - e.g. arrows or not

    init(start: Bubble.Identifier, end: Bubble.Identifier, label: String) {
        self.start = start
        self.end = end
        self.label = label
    }
}

class BubbleLocation: Codable {
    var bubbleID: Bubble.Identifier
    var frame: CGRect
    var fillColor: RGB = RGB.white
    // border style. stroke color

    init(bubbleID: Bubble.Identifier, frame: CGRect, fillColor: RGB) {
        self.bubbleID = bubbleID
        self.frame = frame
        self.fillColor = fillColor
    }
}

class Barrier: Codable {
    var location: Int
    var vertical = true

    init(location: Int, vertical: Bool) {
        self.location = location
        self.vertical = vertical
    }
}

// ----------

class Frame: Codable {
    typealias Identifier = Int

    var identifier: Identifier

    var bubbleIDs: [Bubble.Identifier] = []
    var locations: [BubbleLocation] = []
    var connections: [Connection] = []

    var barriers: [Barrier] = []

    init(ID: Identifier) {
        self.identifier = ID
    }
}
