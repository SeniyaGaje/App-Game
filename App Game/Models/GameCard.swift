//  Model for Light It Up mode.

import Foundation

struct GameCard: Identifiable, Hashable {
    let id: UUID
    var isLit: Bool

    init(isLit: Bool = false) {
        self.id = UUID()
        self.isLit = isLit
    }
}
