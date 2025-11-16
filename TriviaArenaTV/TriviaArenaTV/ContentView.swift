//
//  ContentView.swift
//  TriviaArenaTV
//
//  Created by IM Student on 2025-11-16.
//

import SwiftUI

/// Root view that switches between the different game phases.
struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()

    var body: some View {
        ZStack {
            // Black background
            Color.black
                .ignoresSafeArea()

            // Content based on game phase
            switch viewModel.phase {
            case .lobby:
                LobbyView(viewModel: viewModel)
            case .question:
                QuestionView(viewModel: viewModel)
            case .buzzer:
                BuzzerView(viewModel: viewModel)
            case .scoreboard:
                ScoreboardView(viewModel: viewModel)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            print("ContentView appeared, starting game")
            viewModel.start()
        }
    }
}