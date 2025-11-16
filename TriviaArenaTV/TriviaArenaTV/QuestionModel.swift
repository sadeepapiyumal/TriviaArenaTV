//
//  QuestionModel.swift
//  TriviaArenaTV
//

import Foundation

/// Trivia question model loaded from JSON.
struct Question: Identifiable, Codable {
    let id: UUID
    let text: String
    let answers: [String]
    let correctIndex: Int
}

struct QuestionDeck: Codable {
    let questions: [Question]
}
