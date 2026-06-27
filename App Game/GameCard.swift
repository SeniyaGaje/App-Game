//
//  GameCard.swift
//  App Game
//
//  Model for Light It Up mode.
//

import Foundation

struct GameCard: Identifiable, Hashable {
    let id: UUID = UUID()
    var isLit: Bool = false
}
