//
//  JoinView.swift
//  TriviaArenaController
//

import SwiftUI

/// Initial view where player enters TV IP and name.
struct JoinView: View {
    @EnvironmentObject var client: ControllerClient

    @State private var tvIP: String = ""
    @State private var name: String = ""

    var body: some View {
        Form {
            Section("TV Connection") {
                TextField("Apple TV IP (e.g. 192.168.1.10)", text: $tvIP)
                    .keyboardType(.decimalPad)
            }

            Section("Player") {
                TextField("Your name", text: $name)
            }

            Section {
                Button("Join Room") {
                    client.connect(host: tvIP, name: name.isEmpty ? "Player" : name)
                }
                .disabled(tvIP.isEmpty)
            }

            if let error = client.lastError {
                Section {
                    Text(error)
                        .foregroundColor(.red)
                }
            }

            if client.isConnected {
                NavigationLink("Open Controller") {
                    ControllerMainView()
                }
            }
        }
        .navigationTitle("Join Trivia Arena")
    }
}
