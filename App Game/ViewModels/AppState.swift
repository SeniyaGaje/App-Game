import Foundation
import Combine
import SwiftUI

/// Shared state for deep-link destinations triggered by notification taps.
class AppState: ObservableObject {
    static let shared = AppState()
    
    /// When non-nil, ContentView should navigate to this game immediately.
    @Published var pendingGame: GameMode? = nil
}
