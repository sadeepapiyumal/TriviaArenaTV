//
//  BuzzerView.swift
//  TriviaArenaTV
//

import SwiftUI

/// Buzzer mode UI: first buzz wins.
struct BuzzerView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        VStack(spacing: 40) {
            Text("Buzz Fast!")
                .font(.largeTitle.bold())
                .foregroundColor(.yellow)

            // Show the question
            if let question = viewModel.currentQuestion {
                Text(question.text)
                    .font(.title)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 80)
                
                // Show answer options with correct answer highlighted
                VStack(spacing: 12) {
                    ForEach(Array(question.answers.enumerated()), id: \.offset) { index, answer in
                        HStack {
                            Text(String(UnicodeScalar(65 + index)!))
                                .font(.title2.bold())
                                .frame(width: 40)
                            Text(answer)
                                .font(.title2)
                            Spacer()
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    viewModel.showCorrectAnswer && index == question.correctIndex
                                    ? Color.green.opacity(0.4)
                                    : Color.white.opacity(0.12)
                                )
                        )
                        .padding(.horizontal, 80)
                    }
                }
            }

            if let winnerId = viewModel.buzzerWinnerId,
               let winner = viewModel.players.first(where: { $0.id == winnerId }) {
                Text("\(winner.name) buzzed first!")
                    .font(.title)
                    .foregroundColor(.green)
            } else {
                Text("Waiting for a buzz...")
                    .font(.title2)
                    .foregroundColor(.white)
            }

            ListPlayersView(players: viewModel.players,
                            highlightId: viewModel.buzzerWinnerId)

            HStack(spacing: 40) {
                Button("Next Question") {
                    viewModel.startQuestionRound()
                }
                .buttonStyle(PrimaryTVButtonStyle())

                Button("Scoreboard") {
                    viewModel.startScoreboard()
                }
                .buttonStyle(PrimaryTVButtonStyle())
            }

            Spacer()
        }
        .padding(.top, 80)
    }
}

struct ListPlayersView: View {
    let players: [Player]
    let highlightId: UUID?

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(players) { player in
                    HStack {
                        Text(player.name)
                            .foregroundColor(.white)
                            .font(.title3)
                        Spacer()
                        Text("Score: \(player.score)")
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(player.id == highlightId
                                  ? Color.green.opacity(0.4)
                                  : Color.white.opacity(0.08))
                    )
                    .shadow(radius: player.id == highlightId ? 10 : 2)
                    .scaleEffect(player.id == highlightId ? 1.05 : 1.0)
                    .animation(.spring(), value: highlightId)
                    .padding(.horizontal, 80)
                }
            }
        }
    }
}
