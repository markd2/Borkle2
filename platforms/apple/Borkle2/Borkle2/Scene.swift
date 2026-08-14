// Scene.swift: data structure for a Scene.
//    Scenes have the connections and geometry.
// Trying some new ideas for undo. hope they work.
//    private functions aren't expected to export an undo payload, so are useful
//    as internal tools

import Foundation
import AppKit

struct BubbleGeometry: Codable {
    let bubbleID: Int32

    // height is advisory, generally it'll be determined by word-wrapping the
    // bubble contents. maybe have some knobs to control it (and maybe have
    // scrolling bubble contents?)
    var totalBounds: CGRect {
        let union = [titleRect, bodyRect, keywordsRect]
        .compactMap { $0 }
        .reduce(into: CGRect?.none) { result, next in
            result = result?.union(next) ?? next
        }
        return union ?? CGRect.null
    }

    let titleRect: CGRect?
    let bodyRect: CGRect?
    let keywordsRect: CGRect?
    
    init(bubbleID: Int32, bodyRect: CGRect? = nil,
         titleRect: CGRect? = nil,
         keywordsRect: CGRect? = nil) {
        self.bubbleID = bubbleID
        self.bodyRect = bodyRect
        self.titleRect = titleRect
        self.keywordsRect = keywordsRect
    }
}

class Scene: Codable {

    typealias UndoPayload = AnyObject

    struct Connection: Codable {
        let bubble1ID: Int32
        var bubble1Center: CGPoint
        let bubble2ID: Int32
        var bubble2Center: CGPoint
    }

    /// all the bubbles in this scene
    var bubbleIDs: Set<Int32> = []

    /// The geometry of the bubbles
    var geometries: [BubbleGeometry] = []

    var snugglyRect: CGRect {
        geometries.reduce(into: CGRect.zero) { (accumulator, geometry) in
            accumulator = accumulator.union(geometry.totalBounds)
        }
    }

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
            connection.bubble1Center = g1.totalBounds.center
            connection.bubble2Center = g2.totalBounds.center
        }

        connections.append(connection)
        
        return "addConnection" as NSString
    }

    func geometryFor(_ bubbleID: BubbleID) -> BubbleGeometry? {
        for geometry in geometries {
            if geometry.bubbleID == bubbleID {
                return geometry
            }
        }
        return nil
    }

    func geometryIndexFor(_ bubbleID: BubbleID) -> Int? {
        for (i, geometry) in geometries.enumerated() {
            if geometry.bubbleID == bubbleID {
                return i
            }
        }
        return nil
    }

    // find the geometries for both the given things, used when adding
    // a connection so we can get and cache the center point.

    // if the connection is added before the geometries are available,
    // then we'll add them in changeGeometry.
    func geometriesFor(_ thing1: BubbleID,
                       _ thing2: BubbleID) -> (g1: BubbleGeometry, g2: BubbleGeometry)? {
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
        for i in 0 ..< connections.count {
            let connection = connections[i]
            if connection.bubble1ID == id {
                connections[i].bubble1Center = center
            }

            if connection.bubble2ID == id {
                connections[i].bubble2Center = center
            }
        }
    }

    func changeTitleRect(for id: Int32, to rect: CGRect) -> UndoPayload {
        _ = addID(id)
        let bg = BubbleGeometry(bubbleID: id, bodyRect: rect)
        geometries.append(bg)

        updateConnectionCentersTo(rect.center, for: id)

        return "change title rect \(id) -> \(rect)" as NSString
    }

    func changeGeometry(for id: Int32, to geometry: BubbleGeometry) {

    }

    // Just for the splugne button? Looks like it's _adding_, not
    // _changing_
    func changeGeometry(for id: Int32, to rect: CGRect) -> UndoPayload {
        _ = addID(id)
        let bg = BubbleGeometry(bubbleID: id, bodyRect: rect)
        geometries.append(bg)

        updateConnectionCentersTo(rect.center, for: id)

        return "change geometry \(id) -> \(rect)" as NSString
    }

    func undo(_ payload: UndoPayload) -> UndoPayload {
        Swift.print("no undo")

        // re-apply the work, change payload into a redo
        return "undo" as NSString
    }
}

