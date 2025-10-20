// Copyright 2025 Borkware.

import Foundation

typealias ConnectionId = Int32

struct Connection: Identifiable, Codable {
    let id: ConnectionId
}

struct ConnectionEndpoints {
    let connection:  Connection
    let source: Bubble
    let destination: Bubble
}

struct ConnectionLabel {
    let connection: Connection
    let text: String
}

struct ConnectionStyle {
    let connection: Connection
    // actual style stuff, like line dash, thickness, arrows, etc
}


class Scene {
    private var connections: [Connection] = []
    private var endpoints: [ConnectionEndpoints] = []
    private var labels: [ConnectionLabel] = []
    private var styles: [ConnectionStyle] = []

    func connectionForID(_ id: ConnectionId) throws -> Connection {
        Connection(id: 23)
    }

    func endpoints(for connection: Connection) throws -> ConnectionEndpoints {
        ConnectionEndpoints(connection: Connection(id: 23),
                            source: Bubble(id: 23),
                            destination: Bubble(id: 23))
    }

    func label(for connection: Connection) -> ConnectionLabel? {
        nil
    }

    func style(for connection: Connection) -> ConnectionStyle? {
        nil
    }

}
