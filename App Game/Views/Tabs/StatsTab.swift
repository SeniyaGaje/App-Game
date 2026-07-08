import SwiftUI
import Charts

struct StatsTab: View {
    @StateObject private var vm = StatsVM.shared
    @State private var selectedMode: GameMode = .tapFrenzy
    
    private var themeColor: Color {
        switch selectedMode {
        case .tapFrenzy: return .green
        case .lightItUp: return .cyan
        case .quizRush: return .orange
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.04, green: 0.04, blue: 0.08).ignoresSafeArea()
                
                // Dynamic Background
                Circle()
                    .fill(themeColor.opacity(0.15))
                    .frame(width: 300, height: 300)
                    .blur(radius: 60)
                    .offset(x: 100, y: -200)
                    .animation(.easeInOut(duration: 0.6), value: selectedMode)
                    
                Circle()
                    .fill(themeColor.opacity(0.10))
                    .frame(width: 250, height: 250)
                    .blur(radius: 50)
                    .offset(x: -150, y: 300)
                    .animation(.easeInOut(duration: 0.6), value: selectedMode)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        Picker("Game Mode", selection: $selectedMode) {
                            ForEach(GameMode.allCases) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                        
                        let filtered = vm.sessions.filter { $0.mode == selectedMode }
                        
                        // Leaderboard
                        let sortedSessions = filtered.sorted { $0.score > $1.score }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Leaderboard")
                                .font(.title3.bold())
                                .foregroundStyle(.white)
                                .padding(.horizontal)
                            
                            ForEach(Array(sortedSessions.prefix(10).enumerated()), id: \.element.id) { index, session in
                                HStack(spacing: 16) {
                                    Text("#\(index + 1)")
                                        .font(.headline.bold())
                                        .foregroundStyle(index == 0 ? .yellow : .white.opacity(0.5))
                                        .frame(width: 32, alignment: .leading)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(session.playerName)
                                            .font(.headline.bold())
                                            .foregroundStyle(.white)
                                        Text(session.timestamp.formatted(date: .abbreviated, time: .shortened))
                                            .font(.caption)
                                            .foregroundStyle(.white.opacity(0.6))
                                    }
                                    Spacer()
                                    Text("\(session.score)")
                                        .font(.title2.bold().monospacedDigit())
                                        .foregroundStyle(themeColor)
                                        .shadow(color: themeColor.opacity(0.5), radius: 4)
                                }
                                .padding()
                                .background(.black.opacity(0.35), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(index == 0 ? .yellow.opacity(0.6) : .white.opacity(0.08), lineWidth: index == 0 ? 1.5 : 1)
                                )
                                .padding(.horizontal)
                            }
                            
                            if sortedSessions.isEmpty {
                                Text("No games played yet.")
                                    .foregroundStyle(.white.opacity(0.5))
                                    .padding(.horizontal)
                            }
                        }
                        
                        if !filtered.isEmpty {
                            // Summary
                            HStack(spacing: 12) {
                                StatBlock(title: "Games Played", value: "\(filtered.count)")
                                StatBlock(title: "Best Score", value: "\(vm.bestScore(for: selectedMode))")
                            }
                            .padding(.horizontal)
                            
                            // Chart
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Recent Performance")
                                    .font(.title3.bold())
                                    .foregroundStyle(.white)
                                
                                Chart(filtered.prefix(15).reversed()) { session in
                                    BarMark(
                                        x: .value("Session", session.timestamp, unit: .minute),
                                        y: .value("Score", session.score)
                                    )
                                    .foregroundStyle(themeColor.gradient)
                                    .cornerRadius(4)
                                }
                                .frame(height: 180)
                            }
                            .padding(20)
                            .background(.black.opacity(0.35), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(.white.opacity(0.1), lineWidth: 1))
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Statistics")
            .preferredColorScheme(.dark)
        }
    }
}

#Preview {
    StatsTab()
}
