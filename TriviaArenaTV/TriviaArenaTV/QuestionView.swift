//
//  QuestionView.swift
//  TriviaArenaTV
//

import SwiftUI

/// Question round UI: shows question, answers, and timer bar.
struct QuestionView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        VStack(spacing: 40) {
            Text("Question Round")
                .font(.largeTitle.bold())
                .foregroundColor(.white)

            if let question = viewModel.currentQuestion {
                Text(question.text)
                    .font(.title)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 80)

                VStack(spacing: 20) {
                    ForEach(Array(question.answers.enumerated()), id: \.offset) { index, answer in
                        HStack {
                            Text(String(UnicodeScalar(65 + index)!)) // A/B/C/D
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
            } else {
                Text("Loading question...")
                    .foregroundColor(.gray)
            }

            // Timer bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.1))
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.green)
                        .frame(width: geo.size.width * viewModel.timerProgress)
                        .animation(.linear(duration: 0.1), value: viewModel.timerProgress)
                }
                .frame(height: 20)
                .padding(.horizontal, 80)
            }
            .frame(height: 40)

            HStack(spacing: 40) {
                Button("Buzzer Mode") {
                    viewModel.startBuzzerRound()
                }
                .buttonStyle(PrimaryTVButtonStyle())

                Button("Scoreboard") {
                    viewModel.startScoreboard()
                }
                .buttonStyle(PrimaryTVButtonStyle())
            }

            Spacer()
        }
        .padding(.top, 60)
    }
}

struct PrimaryTVButtonStyle: ButtonStyle {
    @Environment(\.isFocused) var isFocused
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title2.bold())
            .padding(.horizontal, 40)
            .padding(.vertical, 20)
            .background(
                isFocused ? Color.green :
                configuration.isPressed ? Color.orange : Color.blue
            )
            .foregroundColor(.white)
            .cornerRadius(20)
            .scaleEffect(isFocused ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}
