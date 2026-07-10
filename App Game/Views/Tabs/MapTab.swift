import SwiftUI
import MapKit

// MARK: - Location Cluster

/// Groups all sessions that are within ~200m of each other into one pin
struct LocationCluster: Identifiable {
    let id: UUID
    let coordinate: CLLocationCoordinate2D
    let sessions: [GameSession]
    
    var latestThree: [GameSession] {
        Array(sessions.sorted { $0.timestamp > $1.timestamp }.prefix(3))
    }
}

// MARK: - MapTab

struct MapTab: View {
    @StateObject private var vm = StatsVM.shared
    @State private var selectedCluster: LocationCluster? = nil
    @State private var showSessionSheet = false
    
    // Only sessions with a real GPS fix
    private var validSessions: [GameSession] {
        vm.sessions.filter { $0.hasValidLocation }
    }
    
    // Cluster sessions that are within ~200m of each other into single pins
    private var clusters: [LocationCluster] {
        var clusters: [LocationCluster] = []
        for session in validSessions {
            if let idx = clusters.firstIndex(where: { cluster in
                let a = CLLocation(latitude: cluster.coordinate.latitude, longitude: cluster.coordinate.longitude)
                let b = CLLocation(latitude: session.latitude, longitude: session.longitude)
                return a.distance(from: b) < 200
            }) {
                let existing = clusters[idx]
                clusters[idx] = LocationCluster(
                    id: existing.id, // stable ID
                    coordinate: existing.coordinate,
                    sessions: existing.sessions + [session]
                )
            } else {
                clusters.append(LocationCluster(
                    id: session.id, // stable ID
                    coordinate: session.coordinate,
                    sessions: [session]
                ))
            }
        }
        return clusters
    }
    
    var body: some View {
        NavigationStack {
            Map {
                UserAnnotation()
                
                ForEach(clusters) { cluster in
                    Annotation("", coordinate: cluster.coordinate) {
                        PinButton(cluster: cluster) {
                            selectedCluster = cluster
                            showSessionSheet = true
                        }
                    }
                }
            }
            .navigationTitle("Session Map")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .sheet(isPresented: $showSessionSheet) {
                if let cluster = selectedCluster {
                    SessionPopup(cluster: cluster)
                        .presentationDetents([.medium])
                        .presentationDragIndicator(.visible)
                        .preferredColorScheme(.dark)
                }
            }
            // Empty state when no sessions have location yet
            .overlay {
                if validSessions.isEmpty {
                    VStack(spacing: 12) {
                        Spacer()
                        Text("Complete a game to drop a pin!")
                            .font(.subheadline.bold())
                            .foregroundStyle(.white)
                            .padding()
                            .background(.black.opacity(0.75), in: Capsule())
                            .padding(.bottom, 30)
                    }
                }
            }
        }
    }
}

// MARK: - Pin Button

private struct PinButton: View {
    let cluster: LocationCluster
    let onTap: () -> Void
    
    private var dominantMode: GameMode {
        let counts = Dictionary(grouping: cluster.sessions, by: { $0.mode })
            .mapValues { $0.count }
        return counts.max(by: { $0.value < $1.value })?.key ?? .tapFrenzy
    }
    
    private var pinColor: Color {
        switch dominantMode {
        case .tapFrenzy: return .green
        case .lightItUp: return .cyan
        case .quizRush: return .orange
        }
    }
    
    private var pinIcon: String {
        switch dominantMode {
        case .tapFrenzy: return "bolt.fill"
        case .lightItUp: return "lightbulb.max.fill"
        case .quizRush: return "questionmark.circle.fill"
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(pinColor)
                        .frame(width: 48, height: 48)
                        .shadow(color: pinColor.opacity(0.6), radius: 8)
                    
                    Image(systemName: pinIcon)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                    
                    // Session count badge
                    if cluster.sessions.count > 1 {
                        Text("\(cluster.sessions.count)")
                            .font(.system(size: 10, weight: .black))
                            .foregroundStyle(.white)
                            .padding(4)
                            .background(.red, in: Circle())
                            .offset(x: 18, y: -18)
                    }
                }
                
                // Triangle tip
                Image(systemName: "arrowtriangle.down.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(pinColor)
                    .offset(y: -4)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Session Popup Sheet

private struct SessionPopup: View {
    let cluster: LocationCluster
    
    private func modeColor(_ mode: GameMode) -> Color {
        switch mode {
        case .tapFrenzy: return .green
        case .lightItUp: return .cyan
        case .quizRush: return .orange
        }
    }
    
    private func modeIcon(_ mode: GameMode) -> String {
        switch mode {
        case .tapFrenzy: return "bolt.fill"
        case .lightItUp: return "lightbulb.max.fill"
        case .quizRush: return "questionmark.circle.fill"
        }
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.04, green: 0.04, blue: 0.08).ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack(spacing: 12) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.title)
                        .foregroundStyle(.cyan)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Sessions at this location")
                            .font(.title3.bold())
                            .foregroundStyle(.white)
                        Text("\(cluster.sessions.count) total • showing last 3")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.55))
                    }
                }
                .padding(.top, 8)
                
                Divider().background(.white.opacity(0.15))
                
                // Last 3 sessions
                ForEach(cluster.latestThree) { session in
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(modeColor(session.mode).opacity(0.2))
                                .frame(width: 44, height: 44)
                            Image(systemName: modeIcon(session.mode))
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(modeColor(session.mode))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(session.mode.rawValue)
                                .font(.headline.bold())
                                .foregroundStyle(.white)
                            HStack(spacing: 6) {
                                Text(session.playerName)
                                    .foregroundStyle(.white.opacity(0.7))
                                Text("·")
                                    .foregroundStyle(.white.opacity(0.3))
                                Text(session.timestamp.formatted(date: .abbreviated, time: .shortened))
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                            .font(.caption)
                        }
                        
                        Spacer()
                        
                        Text("\(session.score)")
                            .font(.title2.bold().monospacedDigit())
                            .foregroundStyle(modeColor(session.mode))
                            .shadow(color: modeColor(session.mode).opacity(0.5), radius: 4)
                    }
                    .padding()
                    .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    )
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    MapTab()
}
