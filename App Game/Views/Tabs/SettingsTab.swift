import SwiftUI

// "random" is stored as a special sentinel string in AppStorage
private let randomSentinel = "random"

struct SettingsTab: View {
    @AppStorage("playerName") private var playerName: String = "Player 1"
    @AppStorage("dailyChallengeTimestamp") private var dailyChallengeTimestamp: Double = Date().timeIntervalSince1970
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = false
    @AppStorage("dailyChallengeGame") private var dailyChallengeGameRaw: String = randomSentinel
    
    @State private var showResetDialog = false
    
    private var dailyChallengeTime: Binding<Date> {
        Binding(
            get: { Date(timeIntervalSince1970: dailyChallengeTimestamp) },
            set: { dailyChallengeTimestamp = $0.timeIntervalSince1970 }
        )
    }
    
    // nil means "random"
    private var selectedGame: GameMode? {
        GameMode(rawValue: dailyChallengeGameRaw)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.04, green: 0.04, blue: 0.08).ignoresSafeArea()
                
                Form {

                    
                    // MARK: Daily Challenge
                    Section {
                        Toggle("Enable Daily Reminders", isOn: $notificationsEnabled)
                            .onChange(of: notificationsEnabled) { newValue in
                                if newValue { NotificationService.shared.requestPermission() }
                                scheduleNotification()
                            }
                        
                        if notificationsEnabled {
                            DatePicker("Reminder Time",
                                       selection: dailyChallengeTime,
                                       displayedComponents: .hourAndMinute)
                                .onChange(of: dailyChallengeTime.wrappedValue) { _ in
                                    scheduleNotification()
                                }
                            
                            // Game picker — includes a Random option
                            Picker("Challenge Game", selection: $dailyChallengeGameRaw) {
                                // Random option first
                                Label("Random", systemImage: "shuffle")
                                    .tag(randomSentinel)
                                
                                Divider()
                                
                                ForEach(GameMode.allCases) { mode in
                                    Label(mode.rawValue, systemImage: modeIcon(mode))
                                        .tag(mode.rawValue)
                                }
                            }
                            .onChange(of: dailyChallengeGameRaw) { _ in
                                scheduleNotification()
                            }
                            

                        }
                    } header: {
                        Text("Daily Challenge")
                    }
                    .listRowBackground(Color.white.opacity(0.08))
                    
                    // MARK: Data Management
                    Section("Data Management") {
                        Button("Reset All Stats", role: .destructive) {
                            showResetDialog = true
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.08))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .confirmationDialog("Are you sure you want to reset all game stats?",
                                isPresented: $showResetDialog,
                                titleVisibility: .visible) {
                Button("Reset Stats", role: .destructive) { StatsVM.shared.resetStats() }
                Button("Cancel", role: .cancel) {}
            }
            .preferredColorScheme(.dark)
        }
    }
    

    
    private func scheduleNotification() {
        NotificationService.shared.scheduleDailyChallenge(
            at: dailyChallengeTime.wrappedValue,
            isEnabled: notificationsEnabled,
            game: selectedGame  // nil = random
        )
    }
    
    private func modeIcon(_ mode: GameMode) -> String {
        switch mode {
        case .tapFrenzy: return "bolt.fill"
        case .lightItUp: return "lightbulb.max.fill"
        case .quizRush:  return "questionmark.circle.fill"
        }
    }
}

#Preview {
    SettingsTab()
}
