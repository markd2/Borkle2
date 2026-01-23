import Foundation

class BubbleSoup: Codable {
    var bubbles: [Bubble] = []

    @discardableResult func addBubble(_ bubble: Bubble) -> Int32 {
        bubble.ID = Int32(bubbles.count)
        bubbles.append(bubble)
        return bubble.ID
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
