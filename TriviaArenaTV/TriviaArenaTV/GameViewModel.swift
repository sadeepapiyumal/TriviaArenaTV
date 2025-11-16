//
//  GameViewModel.swift
//  TriviaArenaTV
//

import Foundation
import SwiftUI
import Combine

/// High-level game phases.
enum GamePhase: String, Codable {
    case lobby
    case question
    case buzzer
    case scoreboard
}

/// Message coming from controllers.
struct ClientMessage: Codable {
    let type: String          // "join", "answer", "buzz", "ready"
    let name: String?
    let choiceIndex: Int?
}

/// Message sent from TV to controllers.
struct ServerMessage: Codable {
    let type: String          // "state"
    let state: String         // matches GamePhase.rawValue
    let question: Question?
    let players: [Player]
    let winnerId: UUID?
}

/// Main game view model used by tvOS UI and networking.
@MainActor
final class GameViewModel: ObservableObject {

    // Published state for UI

    @Published var phase: GamePhase = .lobby
    @Published var players: [Player] = []
    @Published var currentQuestion: Question?
    @Published var timerProgress: Double = 1.0
    @Published var buzzerWinnerId: UUID?
    @Published var showCorrectAnswer: Bool = false

    // Internal

    private let server = WebSocketServer()
    private var questions: [Question] = []
    private var currentQuestionIndex = 0
    private var connectionToPlayerID: [UUID: UUID] = [:]
    private var timerTask: Task<Void, Never>?
    private var playersWhoAnswered: Set<UUID> = []

    // MARK: - Lifecycle

    init() {
        print("GameViewModel initializing...")
        loadQuestions()
        print("Questions loaded: \(questions.count)")
        configureServerCallbacks()
    }

    func start() {
        // Start server on background thread to avoid blocking UI
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.server.start(port: 8080)
        }
        // Broadcast initial state on main thread
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.broadcastState()
        }
    }

    // MARK: - Server callbacks

    private func configureServerCallbacks() {
        server.onClientConnected = { [weak self] connectionID in
            Task { @MainActor in
                print("Client connected: \(connectionID)")
            }
        }

        server.onClientDisconnected = { [weak self] connectionID in
            Task { @MainActor in
                self?.handleDisconnect(connectionID: connectionID)
            }
        }

        server.onReceiveData = { [weak self] connectionID, data in
            Task { @MainActor in
                self?.handleIncoming(data: data, from: connectionID)
            }
        }
    }

    // MARK: - Incoming messages

    private func handleIncoming(data: Data, from connectionID: UUID) {
        let decoder = JSONDecoder()
        guard let message = try? decoder.decode(ClientMessage.self, from: data) else {
            print("Failed to decode client message")
            return
        }

        switch message.type {
        case "join":
            handleJoin(name: message.name ?? "Player", connectionID: connectionID)
            broadcastState()
        case "answer":
            if let index = message.choiceIndex {
                handleAnswer(choiceIndex: index, from: connectionID)
            }
        case "buzz":
            handleBuzz(from: connectionID)
            broadcastState()
        case "ready":
            handleReady(from: connectionID)
        default:
            break
        }
    }

    private func handleJoin(name: String, connectionID: UUID) {
        // If connection already mapped, update name instead of creating new player.
        if let existingPlayerID = connectionToPlayerID[connectionID],
           let idx = players.firstIndex(where: { $0.id == existingPlayerID }) {
            players[idx].name = name
            players[idx].isConnected = true
        } else {
            let newPlayer = Player(name: name)
            players.append(newPlayer)
            connectionToPlayerID[connectionID] = newPlayer.id
        }
    }

    private func handleDisconnect(connectionID: UUID) {
        guard let playerID = connectionToPlayerID[connectionID],
              let idx = players.firstIndex(where: { $0.id == playerID }) else { return }
        players[idx].isConnected = false
        connectionToPlayerID.removeValue(forKey: connectionID)
        broadcastState()
    }

    private func handleAnswer(choiceIndex: Int, from connectionID: UUID) {
        print("=== handleAnswer called ===")
        print("ConnectionID: \(connectionID.uuidString)")
        print("Current phase: \(phase)")
        print("BuzzerWinnerId: \(buzzerWinnerId?.uuidString ?? "nil")")
        
        guard let question = currentQuestion else {
            print("ERROR: No current question!")
            return
        }
        
        guard let playerID = connectionToPlayerID[connectionID] else {
            print("ERROR: Connection not mapped to player!")
            return
        }
        
        guard let idx = players.firstIndex(where: { $0.id == playerID }) else {
            print("ERROR: Player not found!")
            return
        }

        // Prevent duplicate answers
        guard !playersWhoAnswered.contains(playerID) else {
            print("Player \(players[idx].name) already answered this question")
            return
        }
        
        playersWhoAnswered.insert(playerID)
        let isCorrect = (choiceIndex == question.correctIndex)
        players[idx].lastAnswerCorrect = isCorrect
        
        print("Player: \(players[idx].name), Choice: \(choiceIndex), Correct: \(question.correctIndex), IsCorrect: \(isCorrect)")
        
        if phase == .question {
            // Regular question round: +10 for correct
            if isCorrect {
                players[idx].score += 10
                print("\(players[idx].name) answered correctly! +10 points. New score: \(players[idx].score)")
            }
        } else if phase == .buzzer {
            print("In buzzer phase. Checking if \(playerID.uuidString) == \(buzzerWinnerId?.uuidString ?? "nil")")
            if buzzerWinnerId == playerID {
                // Buzzer round: only the buzzer winner can answer
                // Award +10 if correct, +0 if incorrect
                if isCorrect {
                    players[idx].score += 10
                    print("\(players[idx].name) buzzed and answered correctly! +10 points. New score: \(players[idx].score)")
                } else {
                    print("\(players[idx].name) buzzed but answered incorrectly. No points.")
                }
                
                // Show correct answer immediately and auto-advance to scoreboard after 3 seconds
                showCorrectAnswer = true
                cancelTimer()
                
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
                    self.startScoreboard()
                }
            } else {
                print("Player \(players[idx].name) is not the buzzer winner")
            }
        }
        
        broadcastState()
    }

    private func handleBuzz(from connectionID: UUID) {
        guard phase == .buzzer,
              buzzerWinnerId == nil,
              let playerID = connectionToPlayerID[connectionID],
              let idx = players.firstIndex(where: { $0.id == playerID }) else { return }

        buzzerWinnerId = playerID
        // Don't award points here - wait for them to answer the question
        print("\(players[idx].name) buzzed first!")
    }

    private func handleReady(from connectionID: UUID) {
        guard let playerID = connectionToPlayerID[connectionID],
              let idx = players.firstIndex(where: { $0.id == playerID }) else { return }

        // For now, "ready" is just informational. You could track per-player ready here.
        print("\(players[idx].name) is ready")
    }

    // MARK: - Game flow

    func startLobby() {
        phase = .lobby
        buzzerWinnerId = nil
        currentQuestion = nil
        cancelTimer()
        broadcastState()
    }

    func startQuestionRound() {
        print("startQuestionRound called. Questions count: \(questions.count)")
        guard !questions.isEmpty else {
            print("ERROR: No questions loaded!")
            return
        }

        phase = .question
        buzzerWinnerId = nil
        playersWhoAnswered.removeAll()
        showCorrectAnswer = false

        if currentQuestionIndex >= questions.count {
            currentQuestionIndex = 0
        }
        currentQuestion = questions[currentQuestionIndex]
        print("Starting question: \(currentQuestion?.text ?? "nil")")
        currentQuestionIndex += 1

        players.indices.forEach { idx in
            players[idx].lastAnswerCorrect = nil
        }

        startTimer(duration: 10) { [weak self] in
            Task { @MainActor in
                self?.showCorrectAnswer = true
                // Wait 3 seconds to show the correct answer, then go to scoreboard
                try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
                self?.startScoreboard()
            }
        }

        broadcastState()
    }

    func startBuzzerRound() {
        phase = .buzzer
        buzzerWinnerId = nil
        playersWhoAnswered.removeAll()
        showCorrectAnswer = false
        
        // Start 15-second timer for buzzer round
        startTimer(duration: 15) { [weak self] in
            Task { @MainActor in
                self?.startScoreboard()
            }
        }
        
        broadcastState()
    }

    func startScoreboard() {
        phase = .scoreboard
        cancelTimer()
        broadcastState()
    }

    private func startTimer(duration: Int, onComplete: @escaping () -> Void) {
        cancelTimer()
        timerProgress = 1.0

        timerTask = Task { [weak self] in
            guard let self else { return }
            let total = Double(duration)
            let steps = duration * 10
            for i in 0...steps {
                if Task.isCancelled { return }
                let t = Double(i) / Double(steps)
                await MainActor.run {
                    self.timerProgress = max(0.0, 1.0 - t)
                }
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s
            }
            await MainActor.run {
                self.timerProgress = 0
                onComplete()
            }
        }
    }

    private func cancelTimer() {
        timerTask?.cancel()
        timerTask = nil
        timerProgress = 1.0
    }

    // MARK: - Networking output

    private func broadcastState() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .withoutEscapingSlashes

        let message = ServerMessage(
            type: "state",
            state: phase.rawValue,
            question: currentQuestion,
            players: players,
            winnerId: buzzerWinnerId
        )

        guard let data = try? encoder.encode(message) else {
            print("Failed to encode server message")
            return
        }
        print("Broadcasting state: \(phase.rawValue) with \(players.count) players")
        server.broadcast(data)
    }

    // MARK: - Questions

    private func loadQuestions() {
        guard let url = Bundle.main.url(forResource: "Questions", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Questions.json not found, using fallback questions.")
            questions = [
                Question(id: UUID(),
                         text: "Fallback Question 1",
                         answers: ["A", "B", "C", "D"],
                         correctIndex: 0)
            ]
            return
        }

        let decoder = JSONDecoder()
        if let deck = try? decoder.decode(QuestionDeck.self, from: data) {
            questions = deck.questions
        } else {
            print("Failed to decode Questions.json")
        }
    }
}
