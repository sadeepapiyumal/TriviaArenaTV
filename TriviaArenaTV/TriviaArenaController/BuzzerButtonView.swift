//
//  BuzzerButtonView.swift
//  TriviaArenaController
//

import SwiftUI

/// Large buzzer button.
struct BuzzerButtonView: View {
    @EnvironmentObject var client: ControllerClient

    var body: some View {
        Button(action: {
            client.sendBuzz()
        }) {
            Circle()
                .fill(client.hasBuzzed ? Color.gray : Color.red)
                .overlay(
                    Text(client.hasBuzzed ? "Buzzed" : "BUZZ")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                )
                .shadow(radius: 10)
        }
        .disabled(client.hasBuzzed)
        .padding()
    }
}
