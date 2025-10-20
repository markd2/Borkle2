// Copyright 2025 Borkware.

import Foundation

typealias ConnectionId = Int32

struct Connection: Identifiable, Codable {
    let id: ConnectionId
}

struct ConnectionEndpoints: Codable {
    let connection:  Connection
    let source: Bubble
    let destination: Bubble
}

struct ConnectionLabel: Codable {
    let connection: Connection
    let text: String
}

struct ConnectionStyle: Codable {
    let connection: Connection
    // actual style stuff, like line dash, thickness, arrows, etc
}

struct BubbleGeometry: Codable {
    let bubble: Bubble
    let bounds: CGRect
}

class Scene: Codable {
    private var soup: BubbleSoup

    // subset of the soup's bubbles in this scene
    private var bubbles: [Bubble] = []

    // public so can iterate over them
    var connections: [Connection] = []

    private var endpoints: [ConnectionEndpoints] = []
    private var labels: [ConnectionLabel] = []
    private var styles: [ConnectionStyle] = []

    private var geometries: [BubbleGeometry] = []

    private var nextID: ConnectionId = 0

    init(soup: BubbleSoup) {
        self.soup = soup
    }

    func add(bubble: Bubble) {
        bubbles.append(bubble)
    }

    func set(rect: CGRect, for bubble: Bubble) {
        let bg = BubbleGeometry(bubble: bubble, bounds: rect)
        geometries.append(bg)
    }

    func newConnection() -> Connection {
        nextID += 1
        let connection = Connection(id: nextID)
        connections.append(connection)
        return connection
    }

    func add(connectionFrom thing1: Bubble, to thing2: Bubble) {
        let connection = newConnection()
        let ce = ConnectionEndpoints(connection: connection, source: thing1, destination: thing2)
        endpoints.append(ce)
    }

    func connectionForID(_ id: ConnectionId) throws -> Connection {
        Connection(id: 23)
    }

    func endpoints(for connection: Connection) throws -> ConnectionEndpoints {
        let eps = endpoints.filter { $0.connection.id == connection.id }
        return eps.first! // !!!
    }

    func geometry(for bubble: Bubble) throws -> BubbleGeometry {
        let geometry = geometries.filter { $0.bubble.id == bubble.id }
        return geometry.first! // !!!
    }

    func label(for connection: Connection) -> ConnectionLabel? {
        nil
    }

    func style(for connection: Connection) -> ConnectionStyle? {
        nil
    }

}
