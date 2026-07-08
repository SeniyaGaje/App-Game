import SwiftUI

struct SettingsTab: View {
    @AppStorage("playerName") private var playerName: String = "Player 1"
    @AppStorage("dailyChallengeTimestamp") private var dailyChallengeTimestamp: Double = Date().timeIntervalSince1970
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = false
    
    @State private var showResetDialog = false
    
    private var dailyChallengeTime: Binding<Date> {
        Binding(
            get: { Date(timeIntervalSince1970: dailyChallengeTimestamp) },
            set: { dailyChallengeTimestamp = $0.timeIntervalSince1970 }
        )
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.04, green: 0.04, blue: 0.08).ignoresSafeArea()
                
                Form {
                    Section("Player Profile") {
                        TextField("Your Name", text: $playerName)
                            .textInputAutocapitalization(.words)
                    }
                    .listRowBackground(Color.white.opacity(0.08))
                    
                    Section("Daily Challenge") {
                        Toggle("Enable Daily Reminders", isOn: $notificationsEnabled)
                            .onChange(of: notificationsEnabled) { newValue in
                                if newValue {
                                    NotificationService.shared.requestPermission()
                                }
                                scheduleNotification()
                            }
                        
                        if notificationsEnabled {
                            DatePicker("Reminder Time", selection: dailyChallengeTime, displayedComponents: .hourAndMinute)
                                .onChange(of: dailyChallengeTime.wrappedValue) { _ in
                                    scheduleNotification()
                                }
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.08))
                    
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
            .confirmationDialog("Are you sure you want to reset all game stats?", isPresented: $showResetDialog, titleVisibility: .visible) {
                Button("Reset Stats", role: .destructive) {
                    StatsVM.shared.resetStats()
                }
                Button("Cancel", role: .cancel) {}
            }
            .preferredColorScheme(.dark)
        }
    }
    
    private func scheduleNotification() {
        NotificationService.shared.scheduleDailyChallenge(at: dailyChallengeTime.wrappedValue, isEnabled: notificationsEnabled)
    }
}

#Preview {
    SettingsTab()
}
