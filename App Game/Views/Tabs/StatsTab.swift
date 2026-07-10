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
    
    private var modeIcon: String {
        switch selectedMode {
        case .tapFrenzy: return "bolt.fill"
        case .lightItUp: return "lightbulb.max.fill"
        case .quizRush: return "questionmark.circle.fill"
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
                            HStack {
                                Image(systemName: "trophy.fill")
                                    .foregroundStyle(.yellow)
                                Text("Leaderboard")
                                    .font(.title3.bold())
                                    .foregroundStyle(.white)
                            }
                            .padding(.horizontal)
                            
                            if sortedSessions.isEmpty {
                                HStack {
                                    Spacer()
                                    VStack(spacing: 10) {
                                        Image(systemName: modeIcon)
                                            .font(.system(size: 36))
                                            .foregroundStyle(themeColor.opacity(0.4))
                                        Text("Play \(selectedMode.rawValue) to see your scores here!")
                                            .font(.subheadline)
                                            .foregroundStyle(.white.opacity(0.5))
                                            .multilineTextAlignment(.center)
                                    }
                                    .padding(.vertical, 30)
                                    Spacer()
                                }
                                .padding()
                                .background(.black.opacity(0.35), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .padding(.horizontal)
                            }
                            
                            ForEach(Array(sortedSessions.prefix(10).enumerated()), id: \.element.id) { index, session in
                                HStack(spacing: 16) {
                                    // Rank badge
                                    ZStack {
                                        Circle()
                                            .fill(rankColor(index).opacity(0.2))
                                            .frame(width: 36, height: 36)
                                        Text("\(index + 1)")
                                            .font(.headline.bold())
                                            .foregroundStyle(rankColor(index))
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(session.playerName)
                                            .font(.headline.bold())
                                            .foregroundStyle(.white)
                                        Text(session.timestamp.formatted(date: .abbreviated, time: .shortened))
                                            .font(.caption)
                                            .foregroundStyle(.white.opacity(0.5))
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
                        }
                        
                        if !filtered.isEmpty {
                            // Summary
                            let totalScore = filtered.reduce(0) { $0 + $1.score }
                            let avgScore = totalScore / max(1, filtered.count)
                            
                            HStack(spacing: 12) {
                                StatBlock(title: "Games", value: "\(filtered.count)")
                                StatBlock(title: "Best", value: "\(vm.bestScore(for: selectedMode))")
                                StatBlock(title: "Average", value: "\(avgScore)")
                            }
                            .padding(.horizontal)
                            
                            // Chart — numbered games on x-axis so every session is visible
                            let recentGames = Array(filtered.prefix(15).reversed())
                            let chartData: [(index: Int, score: Int)] = recentGames.enumerated().map { (index: $0.offset + 1, score: $0.element.score) }
                            
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "chart.bar.fill")
                                        .foregroundStyle(themeColor)
                                    Text("Score Progression")
                                        .font(.title3.bold())
                                        .foregroundStyle(.white)
                                    Spacer()
                                    Text("Last \(chartData.count) games")
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.5))
                                }
                                
                                Chart {
                                    ForEach(chartData, id: \.index) { item in
                                        BarMark(
                                            x: .value("Game", "G\(item.index)"),
                                            y: .value("Score", item.score)
                                        )
                                        .foregroundStyle(themeColor.gradient)
                                        .cornerRadius(6)
                                    }
                                    
                                    // Average line
                                    RuleMark(y: .value("Average", avgScore))
                                        .foregroundStyle(.white.opacity(0.5))
                                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 3]))
                                        .annotation(position: .top, alignment: .trailing) {
                                            Text("Avg: \(avgScore)")
                                                .font(.caption2.bold())
                                                .foregroundStyle(.white.opacity(0.7))
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(.black.opacity(0.5), in: Capsule())
                                        }
                                }
                                .chartYAxis {
                                    AxisMarks(position: .leading) { value in
                                        AxisValueLabel()
                                            .foregroundStyle(.white.opacity(0.6))
                                        AxisGridLine()
                                            .foregroundStyle(.white.opacity(0.1))
                                    }
                                }
                                .chartXAxis {
                                    AxisMarks { value in
                                        AxisValueLabel()
                                            .foregroundStyle(.white.opacity(0.6))
                                    }
                                }
                                .frame(height: 200)
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
    
    private func rankColor(_ index: Int) -> Color {
        switch index {
        case 0: return .yellow
        case 1: return Color(white: 0.75)
        case 2: return Color(red: 0.80, green: 0.50, blue: 0.20)
        default: return .white.opacity(0.5)
        }
    }
}

#Preview {
    StatsTab()
}
