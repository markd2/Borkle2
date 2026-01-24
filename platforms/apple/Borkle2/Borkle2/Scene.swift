// Scene.swift: data structure for a Scene.
//    Scenes have the connections and geometry.
// Trying some new ideas for undo. hope they work.
//    private functions aren't expected to export an undo payload, so are useful
//    as internal tools

import Foundation

class Scene: Codable {

    typealias UndoPayload = AnyObject

    struct Connection: Codable {
        let bubble1ID: Int32
        var bubble1Center: CGPoint
        let bubble2ID: Int32
        var bubble2Center: CGPoint
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
    var geometries: [BubbleGeometry] = []

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

    // maybe should have a toggle-connection for the actual UI of dragging bubble
    // onto bubbles, since we'll need to scan anyway.
    func addConnection(from thing1: Int32, to thing2: Int32) -> UndoPayload {
        // first. make sure there's no existing connection
        for connection in connections {
            if (connection.bubble1ID == thing1
                  && connection.bubble2ID == thing2)
                 || (connection.bubble1ID == thing2
                       && connection.bubble2ID == thing1) {
                Swift.print("connection already exists \(thing1) <-> \(thing2)")
                return "no-op undo payload" as NSString
            }
        }

        var connection = Connection(bubble1ID: thing1,
                                    bubble1Center: .zero,
                                    bubble2ID: thing2,
                                    bubble2Center: .zero)

        if let (g1, g2) = geometriesFor(thing1, thing2) {
            connection.bubble1Center = g1.bounds.center
            connection.bubble2Center = g2.bounds.center
        }

        connections.append(connection)
        
        return "addConnection" as NSString
    }

    // find the geometries for both the given things, used when adding a connection
    // so we can get and cache the center point.
    // if the connection is added before the geometries are available, then we'll
    // add them in changeGeometry.
    func geometriesFor(_ thing1: Int32,
                       _ thing2: Int32) -> (g1: BubbleGeometry, g2: BubbleGeometry)? {
        var g1: BubbleGeometry?
        var g2: BubbleGeometry?

        var foundCount = 0

        for geometry in geometries {
            if foundCount == 2 { break }

            if geometry.bubbleID == thing1 {
                g1 = geometry
                foundCount += 1
                continue
            }
            
            if geometry.bubbleID == thing2 {
                g2 = geometry
                foundCount += 1
                continue
            }
        }

        if let g1, let g2 {
            return (g1, g2)
        } else {
            return nil
        }
    }

    func removeConnection(from thing1: Int32, to thing2: Int32) -> UndoPayload {
        Swift.print("no remove connection")
        return "remove connection" as NSString
    }

    private func updateConnectionCentersTo(_ center: CGPoint, for id: Int32) {
        for var connection in connections {
            if connection.bubble1ID == id {
                connection.bubble1Center = center
            }

            if connection.bubble2ID == id {
                connection.bubble2Center = center
            }
        }
    }

    func changeGeometry(for id: Int32, to rect: CGRect) -> UndoPayload {
        _ = addID(id)
        let bg = BubbleGeometry(bubbleID: id, bounds: rect)
        geometries.append(bg)

        updateConnectionCentersTo(rect.center, for: id)

        return "change geometry" as NSString
    }

    func undo(_ payload: UndoPayload) -> UndoPayload {
        Swift.print("no undo")

        // re-apply the work, change payload into a redo
        return "undo" as NSString
    }
}

