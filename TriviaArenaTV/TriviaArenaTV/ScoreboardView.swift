//
//  ScoreboardView.swift
//  TriviaArenaTV
//

import SwiftUI

/// Scoreboard UI with simple correct / incorrect highlighting.
struct ScoreboardView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        VStack(spacing: 40) {
            Text("Scoreboard")
                .font(.largeTitle.bold())
                .foregroundColor(.white)

            ScrollView {
                VStack(spacing: 16) {
                    ForEach(viewModel.players.sorted(by: { $0.score > $1.score })) { player in
                        HStack {
                            Text(player.name)
                                .font(.title2)
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(player.score)")
                                .font(.title2.bold())
                                .foregroundColor(.yellow)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(backgroundColor(for: player))
                        )
                        .padding(.horizontal, 80)
                        .animation(.spring(), value: player.score)
                    }
                }
            }

            HStack(spacing: 40) {
                Button("Next Question") {
                    viewModel.startQuestionRound()
                }
                .buttonStyle(PrimaryTVButtonStyle())

                Button("Lobby") {
                    viewModel.startLobby()
                }
                .buttonStyle(PrimaryTVButtonStyle())
            }

            Spacer()
        }
        .padding(.top, 80)
    }

    private func backgroundColor(for player: Player) -> Color {
        switch player.lastAnswerCorrect {
        case .some(true):
            return Color.green.opacity(0.3)
        case .some(false):
            return Color.red.opacity(0.3)
        case .none:
            return Color.white.opacity(0.1)
        }
    }
}
