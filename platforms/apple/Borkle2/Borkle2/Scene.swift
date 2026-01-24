// Scene.swift: data structure for a Scene.
//    Scenes have the connections and geometry.

import Foundation

class Scene: Codable {

    typealias UndoPayload = AnyObject

    struct Connection: Codable {
        let bubble1ID: Int32
        let bubble2ID: Int32
    }

    struct BubbleGeometry: Codable {
        let bubbleID: Int32

        // height is advisory, generally it'll be determined by word-wrapping the
        // bubble contents. maybe have some knobs to control it (and maybe have
        // scrolling bubble contents?)
        let bounds: CGRect
    }

    /// all the bubbles in this scene
    var bubbleIDs: Set<Int32> = []

    /// The geometry of the bubbles
    var geometry: [BubbleGeometry] = []

    /// connections (if any) between pairs of bubbles
    var connections: [Connection] = []

    func addID(_ id: Int32) -> UndoPayload {
        bubbleIDs.insert(id)
        return "add id" as NSString
    }

    // Remove any connections and geometry with this ID.
    // returns an undo payload
    func removeID(_ id: Int32) -> UndoPayload {
        return "remove id" as NSString
    }

    func addConnection(from thing1: Int32, to thing2: Int32) -> UndoPayload {
        return "add connection" as NSString
    }

    func removeConnection(from thing1: Int32, to thing2: Int32) -> UndoPayload {
        return "remove connection" as NSString
    }

    func changeGeometry(for id: Int32, to rect: CGRect) -> UndoPayload {
        _ = addID(id)
        let bg = BubbleGeometry(bubbleID: id, bounds: rect)
        geometry.append(bg)
        return "change geometry" as NSString
    }

    func undo(_ payload: UndoPayload) -> UndoPayload {
        // re-apply the work, change payload into a redo
        return "undo" as NSString
    }
}

