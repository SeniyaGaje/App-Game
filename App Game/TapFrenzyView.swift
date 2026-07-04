//
//  TapFrenzyView.swift
//  App Game
//
//  Simple tap-as-fast-as-you-can mode.
//

import SwiftUI

struct TapFrenzyView: View {
    @AppStorage("tapFrenzyHighScore") private var highScore: Int = 0
    @AppStorage("roundLength") private var roundLength: Int = 60

    @State private var score: Int = 0
    @State private var timeLeft: Int = 60
    @State private var isPlaying: Bool = false
    @State private var timer: Timer?
    @State private var showSettings: Bool = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.06, blue: 0.12),
                    Color.green.opacity(0.22),
                    Color.blue.opacity(0.26)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.green.opacity(0.16))
                .frame(width: 220, height: 220)
                .blur(radius: 42)
                .offset(x: 150, y: -220)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Tap Frenzy")
                            .font(.system(size: 36, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                        Text("Tap as fast as you can before the timer runs out.")
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.82))
                        Text(isPlaying ? "Round in progress" : "Tap the circle to begin.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.72))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(.white.opacity(0.12), lineWidth: 1)
                    )

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        StatBlock(title: "Score", value: "\(score)")
                        StatBlock(title: "Best", value: "\(highScore)")
                        StatBlock(title: "Time", value: "\(timeLeft)s", isWarning: isPlaying && timeLeft <= 5)
                    }

                    VStack(spacing: 14) {
                        Text("Your round length is set from the settings button in the top-right corner.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.76))
                            .multilineTextAlignment(.center)

                        Button(action: handleTap) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                isPlaying ? Color.green.opacity(0.95) : Color.white.opacity(0.2),
                                                isPlaying ? Color.mint.opacity(0.8) : Color.gray.opacity(0.22)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 250, height: 250)
                                    .overlay(
                                        Circle()
                                            .stroke(.white.opacity(0.18), lineWidth: 1)
                                    )
                                    .shadow(color: (isPlaying ? Color.green : Color.black).opacity(0.32), radius: 18, x: 0, y: 12)

                                VStack(spacing: 6) {
                                    Text(isPlaying ? "Tap" : "Start")
                                        .font(.system(size: 42, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white)
                                    Text(isPlaying ? "Every tap counts" : "Begin a fast round")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(.white.opacity(0.8))
                                }
                            }
                            .scaleEffect(isPlaying ? 1.02 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: isPlaying)
                        }
                        .buttonStyle(.plain)
                        .disabled(isPlaying && timeLeft == 0)

                        HStack(spacing: 12) {
                            Button(isPlaying ? "Restart round" : "Reset") {
                                resetGame(start: isPlaying)
                            }
                            .buttonStyle(.borderedProminent)

                            if isPlaying {
                                Button("Stop") {
                                    resetGame(start: false)
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(.white.opacity(0.12), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 18)
            }
        }
        .navigationTitle("Tap Frenzy")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                SettingsToolbarButton {
                    showSettings = true
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(roundLength: $roundLength)
        }
        .onAppear {
            timeLeft = roundLength
        }
        .onChange(of: roundLength) { newValue in
            if !isPlaying {
                timeLeft = newValue
            }
        }
        .onDisappear { stopTimer() }
    }

    private func handleTap() {
        if !isPlaying {
            resetGame(start: true)
        } else if timeLeft > 0 {
            score += 1
        }
    }

    private func resetGame(start: Bool) {
        score = 0
        timeLeft = roundLength
        if start {
            isPlaying = true
            startTimer()
        } else {
            isPlaying = false
            stopTimer()
        }
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeLeft > 0 {
                timeLeft -= 1
            }
            if timeLeft == 0 {
                isPlaying = false
                stopTimer()
                if score > highScore { highScore = score }
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

#Preview {
    NavigationStack {
        TapFrenzyView()
    }
}
