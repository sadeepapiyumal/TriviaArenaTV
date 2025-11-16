//
//  ControllerClient.swift
//  TriviaArenaController
//

import Foundation
import SwiftUI

// Mirror models from TV for decoding.
struct ControllerQuestion: Identifiable, Codable {
    let id: UUID
    let text: String
    let answers: [String]
    let correctIndex: Int
}

struct ControllerPlayer: Identifiable, Codable {
    let id: UUID
    let name: String
    let score: Int
    let isConnected: Bool
    let lastAnswerCorrect: Bool?
}

struct ControllerServerMessage: Codable {
    let type: String        // "state"
    let state: String       // "lobby", "question", etc.
    let question: ControllerQuestion?
    let players: [ControllerPlayer]?
    let winnerId: UUID?
}

struct ControllerClientMessage: Codable {
    let type: String        // "join", "answer", "buzz", "ready"
    let name: String?
    let choiceIndex: Int?
}

/// Connection + game state for the controller app.
@MainActor
final class ControllerClient: ObservableObject {

    enum Phase {
        case disconnected
        case lobby
        case question
        case buzzer
        case scoreboard
    }

    @Published var phase: Phase = .disconnected
    @Published var isConnected: Bool = false
    @Published var lastError: String?
    @Published var playerName: String = ""
    @Published var tvHost: String = ""
    @Published var currentQuestion: ControllerQuestion?
    @Published var players: [ControllerPlayer] = []
    @Published var hasAnsweredCurrent: Bool = false
    @Published var hasBuzzed: Bool = false
    @Published var buzzerWinnerId: UUID?

    private var webSocketTask: URLSessionWebSocketTask?
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private var lastURL: URL?
    private var reconnectTimer: Timer?
    private var shouldReconnect: Bool = false

    // MARK: - Connection

    func connect(host: String, port: UInt16 = 8080, name: String) {
        disconnect()
        playerName = name
        tvHost = host

        guard let url = URL(string: "ws://\(host):\(port)") else {
            lastError = "Invalid host"
            return
        }

        let session = URLSession(configuration: .default)
        let task = session.webSocketTask(with: url)
        webSocketTask = task
        lastURL = url
        shouldReconnect = true

        task.resume()
        listen()

        sendJoin()
    }

    func disconnect() {
        shouldReconnect = false
        reconnectTimer?.invalidate()
        reconnectTimer = nil

        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        isConnected = false
        phase = .disconnected
    }

    private func attemptReconnect() {
        guard shouldReconnect, let url = lastURL else { return }
        reconnectTimer?.invalidate()
        reconnectTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            guard let self else { return }
            let session = URLSession(configuration: .default)
            let task = session.webSocketTask(with: url)
            self.webSocketTask = task
            task.resume()
            self.listen()
            self.sendJoin()
        }
    }

    // MARK: - Messaging

    private func listen() {
        webSocketTask?.receive { [weak self] result in
            guard let self else { return }

            switch result {
            case .failure(let error):
                Task { @MainActor in
                    self.isConnected = false
                    self.lastError = error.localizedDescription
                    self.attemptReconnect()
                }
            case .success(let message):
                Task { @MainActor in
                    self.isConnected = true
                    self.lastError = nil
                    switch message {
                    case .data(let data):
                        self.handle(data: data)
                    case .string(let text):
                        if let data = text.data(using: .utf8) {
                            self.handle(data: data)
                        }
                    @unknown default:
                        break
                    }
                    self.listen()
                }
            }
        }
    }

    private func handle(data: Data) {
        guard let message = try? decoder.decode(ControllerServerMessage.self, from: data) else {
            print("Failed to decode server message")
            return
        }

        switch message.state {
        case "lobby":
            phase = .lobby
        case "question":
            phase = .question
            hasAnsweredCurrent = false
            hasBuzzed = false
        case "buzzer":
            phase = .buzzer
        case "scoreboard":
            phase = .scoreboard
        default:
            break
        }

        currentQuestion = message.question
        players = message.players ?? []
        buzzerWinnerId = message.winnerId
    }

    private func send(_ clientMessage: ControllerClientMessage) {
        guard let task = webSocketTask else { return }
        guard let data = try? encoder.encode(clientMessage) else { return }

        let text = String(data: data, encoding: .utf8) ?? ""
        task.send(.string(text)) { [weak self] error in
            Task { @MainActor in
                if let error = error {
                    self?.lastError = error.localizedDescription
                }
            }
        }
    }

    // MARK: - Public actions

    func sendJoin() {
        let message = ControllerClientMessage(type: "join",
                                              name: playerName,
                                              choiceIndex: nil)
        send(message)
    }

    func sendAnswer(index: Int) {
        guard phase == .question, !hasAnsweredCurrent else { return }
        hasAnsweredCurrent = true
        let message = ControllerClientMessage(type: "answer",
                                              name: nil,
                                              choiceIndex: index)
        send(message)
    }

    func sendBuzz() {
        guard phase == .buzzer, !hasBuzzed else { return }
        hasBuzzed = true
        let message = ControllerClientMessage(type: "buzz",
                                              name: nil,
                                              choiceIndex: nil)
        send(message)
    }

    func sendReady() {
        let message = ControllerClientMessage(type: "ready",
                                              name: nil,
                                              choiceIndex: nil)
        send(message)
    }
}
