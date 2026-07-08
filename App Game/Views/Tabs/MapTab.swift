import SwiftUI
import MapKit

struct MapTab: View {
    @StateObject private var vm = StatsVM.shared
    
    var body: some View {
        NavigationStack {
            Map {
                ForEach(vm.sessions) { session in
                    Annotation(session.mode.rawValue, coordinate: session.coordinate) {
                        VStack(spacing: 4) {
                            Image(systemName: icon(for: session.mode))
                                .font(.title3)
                                .padding(8)
                                .background(color(for: session.mode))
                                .clipShape(Circle())
                                .foregroundStyle(.white)
                                .shadow(radius: 4)
                            Text("\(session.score)")
                                .font(.caption.bold())
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.black.opacity(0.8), in: Capsule())
                                .foregroundStyle(.white)
                        }
                    }
                }
            }
            .navigationTitle("Session Map")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .onAppear {
                LocationService.shared.requestPermission()
                LocationService.shared.startUpdating()
            }
        }
    }
    
    private func icon(for mode: GameMode) -> String {
        switch mode {
        case .tapFrenzy: return "bolt.fill"
        case .lightItUp: return "lightbulb.max.fill"
        case .quizRush: return "questionmark.circle.fill"
        }
    }
    
    private func color(for mode: GameMode) -> Color {
        switch mode {
        case .tapFrenzy: return .green
        case .lightItUp: return .cyan
        case .quizRush: return .orange
        }
    }
}

#Preview {
    MapTab()
}
