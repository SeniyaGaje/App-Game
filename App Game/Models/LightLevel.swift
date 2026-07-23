//  LightLevel.swift

import SwiftUI

enum LightLevel: Int, CaseIterable {
    case level1 = 1
    case level2 = 2
    case level3 = 3
    case level4 = 4

    // Number of cards on the grid
    var cardCount: Int {
        switch self {
        case .level1: return 3   // 1 row of 3
        case .level2: return 4   // 1 row of 4
        case .level3: return 6   // 2 × 3
        case .level4: return 9   // 3 × 3
        }
    }

    // Number of simultaneously lit cards
    var litCount: Int {
        switch self {
        case .level1, .level2, .level3: return 1
        case .level4:                   return 2
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

    // Distinct glow colour per level.
    var glowColor: Color {
        switch self {
        case .level1: return .green
        case .level2: return Color(red: 0.40, green: 0.70, blue: 1.0)   // blue
        case .level3: return Color(red: 0.85, green: 0.68, blue: 0.22)  // yellow
        case .level4: return Color(red: 0.95, green: 0.32, blue: 0.32)  // red
        }
    }

    // Grid columns layout for LazyVGrid
    var gridColumns: [GridItem] {
        switch self {
        case .level1: return Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)
        case .level2: return Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)
        case .level3: return Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)
        case .level4: return Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)
        }
    }

    // Derive the correct level from elapsed seconds
    static func level(forElapsed elapsed: Int, totalDuration: Int = 60) -> LightLevel {
        let block = max(1, totalDuration / 4)
        switch elapsed {
        case 0..<block:       return .level1
        case block..<(2 * block): return .level2
        case (2 * block)..<(3 * block): return .level3
        default:              return .level4
        }
    }
}
 
