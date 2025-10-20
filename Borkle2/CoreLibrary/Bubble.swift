// Copyright 2025 Borkware.

import Foundation

typealias BubbleId = Int32

struct Bubble: Identifiable, Codable {
    let id: BubbleId
}

struct BubbleTag: Codable {
    let bubble: Bubble
    let tag: String
}

enum BubbleChunk: Codable {
    case title(String)
    case text(AttributedString)
    case image(imageName: String)
    case taglist(tags: [BubbleTag])
}

class BubbleSoup: Codable {
    private var bubbles: [Bubble] = []
    private var tags: [BubbleTag] = []
    private var chunks: [BubbleId: BubbleChunk] = [:]

    func bubbleForID(_ id: BubbleId) throws -> Bubble {
        Bubble(id: 23)
    }

    func chunks(for bubble: Bubble) -> [BubbleChunk] {
        []
    }

    func tags(for bubble: Bubble) -> [BubbleTag] {
        []
    }
}
