//
//  LobbyView.swift
//  TriviaArenaTV
//

import SwiftUI

/// Lobby UI showing connected players.
struct LobbyView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        VStack(spacing: 40) {
            Text("Trivia Arena")
                .font(.largeTitle.bold())
                .foregroundColor(.white)

            Text("Waiting for Players...")
                .font(.title2)
                .foregroundColor(.yellow)

            ScrollView {
                VStack(spacing: 16) {
                    ForEach(viewModel.players) { player in
                        HStack {
                            Circle()
                                .fill(player.isConnected ? Color.green : Color.red)
                                .frame(width: 24, height: 24)
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
                                .fill(Color.white.opacity(0.08))
                        )
                        .shadow(radius: 4)
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 80)
                .animation(.spring(), value: viewModel.players)
            }

            if !viewModel.players.isEmpty {
                Button("Start Game") {
                    print("Start Game button tapped!")
                    viewModel.startQuestionRound()
                }
                .font(.title2.bold())
                .padding(40)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(20)
            }

            Spacer()
        }
        .padding(.top, 80)
    }
}
