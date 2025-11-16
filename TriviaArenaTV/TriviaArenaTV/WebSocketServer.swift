//
//  WebSocketServer.swift
//  TriviaArenaTV
//
//  Simple WebSocket server using Network.framework.
//

import Foundation
import Network

/// Lightweight wrapper around NWListener for WebSocket connections on tvOS.
final class WebSocketServer {

    struct Client {
        let id: UUID
        let connection: NWConnection
    }

    private var listener: NWListener?
    private let queue = DispatchQueue(label: "TriviaArenaTV.WebSocketServer")
    private(set) var clients: [UUID: Client] = [:]

    /// Called when a client connects.
    var onClientConnected: ((UUID) -> Void)?

    /// Called when a client disconnects.
    var onClientDisconnected: ((UUID) -> Void)?

    /// Called when a client sends raw Data (UTF-8 JSON).
    var onReceiveData: ((UUID, Data) -> Void)?

    /// Start listening on given port as WebSocket server.
    func start(port: UInt16 = 8080) {
        guard listener == nil else { return }

        let parameters = NWParameters(tls: nil)
        let wsOptions = NWProtocolWebSocket.Options()
        wsOptions.autoReplyPing = true
        parameters.defaultProtocolStack.applicationProtocols.insert(wsOptions, at: 0)

        do {
            let portObj = try NWEndpoint.Port(rawValue: port).unwrap()
            let listener = try NWListener(using: parameters, on: portObj)
            self.listener = listener

            listener.newConnectionHandler = { [weak self] connection in
                self?.setupConnection(connection)
            }

            listener.stateUpdateHandler = { state in
                print("WebSocket listener state: \(state)")
            }

            listener.start(queue: queue)
        } catch {
            print("Failed to start WebSocket listener: \(error)")
        }
    }

    /// Stop listener and close all clients.
    func stop() {
        listener?.cancel()
        listener = nil
        clients.values.forEach { $0.connection.cancel() }
        clients.removeAll()
    }

    /// Broadcast data to all connected clients.
    func broadcast(_ data: Data) {
        for client in clients.values {
            send(data, to: client.id)
        }
    }

    /// Send data to a specific client.
    func send(_ data: Data, to clientID: UUID) {
        guard let client = clients[clientID] else { return }
        let metadata = NWProtocolWebSocket.Metadata(opcode: .text)
        let context = NWConnection.ContentContext(identifier: "text",
                                                  metadata: [metadata])

        client.connection.send(content: data,
                               contentContext: context,
                               isComplete: true,
                               completion: .idempotent)
    }

    // MARK: - Internal

    private func setupConnection(_ connection: NWConnection) {
        let clientID = UUID()
        let client = Client(id: clientID, connection: connection)
        clients[clientID] = client

        connection.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                self?.onClientConnected?(clientID)
                self?.receive(on: client)
            case .failed, .cancelled:
                self?.clients.removeValue(forKey: clientID)
                self?.onClientDisconnected?(clientID)
            default:
                break
            }
        }

        connection.start(queue: queue)
    }

    private func receive(on client: Client) {
        client.connection.receiveMessage { [weak self] data, _, _, error in
            if let data = data, !data.isEmpty {
                self?.onReceiveData?(client.id, data)
            }

            if error == nil {
                self?.receive(on: client)
            } else {
                self?.clients.removeValue(forKey: client.id)
                self?.onClientDisconnected?(client.id)
            }
        }
    }
}

private extension Optional where Wrapped == NWEndpoint.Port {
    func unwrap() throws -> NWEndpoint.Port {
        guard let value = self else {
            throw NSError(domain: "TriviaArenaTV",
                          code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Invalid port"])
        }
        return value
    }
}
