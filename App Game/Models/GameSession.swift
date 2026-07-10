import Foundation
import CoreLocation

struct GameSession: Identifiable, Codable {
    let id: UUID
    let mode: GameMode
    let score: Int
    let timestamp: Date
    let latitude: Double
    let longitude: Double
    let playerName: String
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    /// True only when a real GPS fix was captured (not the 0.0/0.0 sentinel)
    var hasValidLocation: Bool {
        latitude != 0.0 && longitude != 0.0
    }
}
