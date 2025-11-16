//
//  PlayerModel.swift
//  TriviaArenaTV
//

import Foundation

/// Player model used on the TV and mirrored to controllers.
struct Player: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var score: Int
    var isConnected: Bool
    var lastAnswerCorrect: Bool?

    init(id: UUID = UUID(),
         name: String,
         score: Int = 0,
         isConnected: Bool = true,
         lastAnswerCorrect: Bool? = nil) {
        self.id = id
        self.name = name
        self.score = score
        self.isConnected = isConnected
        self.lastAnswerCorrect = lastAnswerCorrect
    }
}
