//
//  AnswerButtonsView.swift
//  TriviaArenaController
//

import SwiftUI

/// Answer buttons A/B/C/D.
struct AnswerButtonsView: View {
    @EnvironmentObject var client: ControllerClient
    let question: ControllerQuestion

    var body: some View {
        VStack(spacing: 12) {
            ForEach(Array(question.answers.enumerated()), id: \.offset) { index, answer in
                Button(action: {
                    client.sendAnswer(index: index)
                }) {
                    HStack {
                        Text(String(UnicodeScalar(65 + index)!))
                            .bold()
                            .frame(width: 24)
                        Text(answer)
                        Spacer()
                    }
                    .padding()
                    .background(buttonBackground(for: index))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(client.hasAnsweredCurrent)
            }
        }
    }

    private func buttonBackground(for index: Int) -> Color {
        if client.hasAnsweredCurrent {
            return Color.gray
        } else {
            return Color.blue
        }
    }
}
