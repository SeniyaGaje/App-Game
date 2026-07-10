import Foundation
import Combine
import CoreLocation

class StatsVM: ObservableObject {
    static let shared = StatsVM()
    
    @Published var sessions: [GameSession] = []
    
    private let sessionsKey = "gameSessions"
    
    init() {
        loadSessions()
    }
    
    func addSession(mode: GameMode, score: Int, playerName: String) {
        // Use real GPS coordinates only. 0.0/0.0 means "no location recorded yet".
        // This will be non-zero once the user grants location permission.
        let loc = LocationService.shared.currentLocation
        let lat = loc?.latitude ?? 0.0
        let lon = loc?.longitude ?? 0.0
        
        let newSession = GameSession(
            id: UUID(),
            mode: mode,
            score: score,
            timestamp: Date(),
            latitude: lat,
            longitude: lon,
            playerName: playerName.trimmingCharacters(in: .whitespaces).isEmpty ? "Player 1" : playerName
        )
        
        sessions.insert(newSession, at: 0)
        saveSessions()
    }
    
    func resetStats() {
        sessions.removeAll()
        saveSessions()
    }
    
    private func saveSessions() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: sessionsKey)
        }
    }
    
    private func loadSessions() {
        if let data = UserDefaults.standard.data(forKey: sessionsKey),
           let decoded = try? JSONDecoder().decode([GameSession].self, from: data) {
            sessions = decoded
        }
    }
    
    func bestScore(for mode: GameMode) -> Int {
        sessions.filter { $0.mode == mode }.map { $0.score }.max() ?? 0
    }
}
