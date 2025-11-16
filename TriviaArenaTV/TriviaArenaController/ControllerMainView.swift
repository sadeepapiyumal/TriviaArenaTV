//
//  ControllerMainView.swift
//  TriviaArenaController
//

import SwiftUI

/// Main controller UI that switches with the game phase.
struct ControllerMainView: View {
    @EnvironmentObject var client: ControllerClient

    var body: some View {
        VStack {
            switch client.phase {
            case .disconnected:
                Text("Disconnected")
            case .lobby:
                lobbyContent
            case .question:
                questionContent
            case .buzzer:
                buzzerContent
            case .scoreboard:
                scoreboardContent
            }
        }
        .padding()
        .navigationTitle("Controller")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Ready") {
                    client.sendReady()
                }
            }
        }
    }

    private var lobbyContent: some View {
        VStack(spacing: 16) {
            Text("Lobby")
                .font(.title.bold())
            Text("Waiting for game to start...")
                .foregroundColor(.gray)
            Text("Players:")
                .font(.headline)

            List(client.players) { player in
                HStack {
                    Text(player.name)
                    Spacer()
                    Text("\(player.score)")
                }
            }
        }
    }

    private var questionContent: some View {
        VStack(spacing: 20) {
            if let question = client.currentQuestion {
                Text(question.text)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()

                AnswerButtonsView(question: question)
            } else {
                Text("Awaiting question...")
            }
        }
    }

    private var buzzerContent: some View {
        VStack(spacing: 20) {
            Text("Buzz Fast!")
                .font(.largeTitle.bold())

            BuzzerButtonView()
                .frame(height: 200)

            if let winnerId = client.buzzerWinnerId,
               let winner = client.players.first(where: { $0.id == winnerId }) {
                Text("\(winner.name) buzzed first!")
                    .foregroundColor(.green)
            }
        }
    }

    private var scoreboardContent: some View {
        VStack(spacing: 16) {
            Text("Scoreboard")
                .font(.title.bold())

            List(client.players.sorted(by: { $0.score > $1.score })) { player in
                HStack {
                    Text(player.name)
                    Spacer()
                    Text("\(player.score)")
                        .bold()
                }
            }
        }
    }
}
