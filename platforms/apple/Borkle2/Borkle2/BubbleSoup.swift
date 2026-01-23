import Foundation

class BubbleSoup: Codable {
    var bubbles: [Bubble] = []

    @discardableResult func addBubble(_ bubble: Bubble) -> Int32 {
        bubble.ID = Int32(bubbles.count)
        bubbles.append(bubble)
        return bubble.ID
    }

    // unhappy with this because it calculate the entire set on every
    // call, but we don't (won't?) have a "monitor each of the bubbles for
    // a tag change" mechanism
    var allTags: [String] {
        var taggage = Set<String>()

        bubbles.forEach { bubble in
            guard let tags = bubble.tags else { return }
            taggage.formUnion(tags)
        }

        return Array(taggage).sorted()
    }

    func addBubbles(_ bubbles: [Bubble]) {
        bubbles.forEach { 
            addBubble($0)
        }
    }

    func verify() {
        for i in 0 ..< bubbles.count {
            if bubbles[i].ID != i {
                print("ID \(i) (vs \(bubbles[i].ID)) mismatch")
            }
        }
        print("yay (\(bubbles.count) bubbles)")
    }
}
