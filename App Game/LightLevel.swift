//
//  LightLevel.swift
//  App Game
//
//  Level definitions and helpers for Light It Up mode.
//

import SwiftUI

enum LightLevel: Int, CaseIterable {
    case level1 = 1
    case level2 = 2
    case level3 = 3
    case level4 = 4

    // Returns the number of cards for the level
    var cardCount: Int {
        switch self {
        case .level1: return 3       // 1 row of 3
        case .level2: return 4       // 1 row of 4
        case .level3: return 6       // 2 x 3
        case .level4: return 9       // 3 x 3
        }
    }

    // Number of simultaneously lit cards
    var litCount: Int {
        switch self {
        case .level1, .level2, .level3: return 1
        case .level4: return 2
        }
    }

    // How long a card stays lit (seconds)
    var litWindow: TimeInterval {
        switch self {
        case .level1: return 1.5
        case .level2: return 1.2
        case .level3: return 1.0
        case .level4: return 0.8
        }
    }

    // Glow color for the level
    var glowColor: Color {
        switch self {
        case .level1: return .green
        case .level2: return .blue
        case .level3: return .yellow
        case .level4: return .red
        }
    }

    // Grid columns layout for LazyVGrid
    var gridColumns: [GridItem] {
        switch self {
        case .level1: return Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)
        case .level2: return Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)
        case .level3: return Array(repeating: GridItem(.flexible(), spacing: 12), count: 3) // 2x3 achieved by cardCount
        case .level4: return Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)
        }
    }
}
