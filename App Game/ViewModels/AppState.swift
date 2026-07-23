import Foundation
import Combine
import SwiftUI

class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var pendingGame: GameMode? = nil
}
