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
    @State private var tapScale: CGFloat = 1.0

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
                .fill(Color.green.opacity(0.18))
                .frame(width: 260, height: 260)
                .blur(radius: 48)
                .offset(x: 150, y: -220)

            Circle()
                .fill(Color.mint.opacity(0.12))
                .frame(width: 200, height: 200)
                .blur(radius: 40)
                .offset(x: -140, y: 300)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {

                    // MARK: Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tap Frenzy")
                            .font(.system(size: 36, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                        Text(isPlaying ? "Round in progress — keep going!" : "Tap the circle as fast as you can.")
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.78))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(Color(red: 0.10, green: 0.12, blue: 0.22), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(.white.opacity(0.15), lineWidth: 1)
                    )

                    // MARK: Stats
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        StatBlock(title: "Score", value: "\(score)")
                        StatBlock(title: "Best", value: "\(highScore)")
                        StatBlock(title: "Time", value: "\(timeLeft)s", isWarning: isPlaying && timeLeft <= 5)
                    }

                    // MARK: Tap Circle
                    VStack(spacing: 20) {
                        Button(action: handleTap) {
                            ZStack {
                                // Outer glow ring
                                Circle()
                                    .stroke(
                                        isPlaying
                                            ? LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing)
                                            : LinearGradient(colors: [.white.opacity(0.25), .white.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing),
                                        lineWidth: 3
                                    )
                                    .frame(width: 266, height: 266)
                                    .blur(radius: isPlaying ? 2 : 0)

                                Circle()
                                    .fill(
                                        isPlaying
                                            ? LinearGradient(
                                                colors: [Color.green.opacity(0.9), Color.mint.opacity(0.75)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                              )
                                            : LinearGradient(
                                                colors: [Color(red: 0.12, green: 0.14, blue: 0.22), Color(red: 0.08, green: 0.10, blue: 0.18)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                              )
                                    )
                                    .frame(width: 258, height: 258)
                                    .shadow(color: isPlaying ? Color.green.opacity(0.55) : Color.black.opacity(0.45), radius: isPlaying ? 28 : 16, x: 0, y: 12)

                                VStack(spacing: 6) {
                                    Text(isPlaying ? "TAP" : "START")
                                        .font(.system(size: 44, weight: .heavy, design: .rounded))
                                        .foregroundStyle(isPlaying ? .white : Color.green)
                                    Text(isPlaying ? "Every tap counts" : "Begin a fast round")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(isPlaying ? .white.opacity(0.85) : Color.white.opacity(0.55))
                                }
                            }
                            .scaleEffect(tapScale)
                        }
                        .buttonStyle(.plain)
                        .disabled(isPlaying && timeLeft == 0)

                        // MARK: Controls
                        HStack(spacing: 12) {
                            Button(isPlaying ? "Restart" : "Reset") {
                                resetGame(start: isPlaying)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green.opacity(0.85))

                            if isPlaying {
                                Button("Stop") {
                                    resetGame(start: false)
                                }
                                .buttonStyle(.bordered)
                                .tint(.white.opacity(0.8))
                            }
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 0.10, green: 0.12, blue: 0.22), in: RoundedRectangle(cornerRadius: 32, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .stroke(.white.opacity(0.15), lineWidth: 1)
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
        .preferredColorScheme(.dark)
    }

    private func handleTap() {
        if !isPlaying {
            resetGame(start: true)
        } else if timeLeft > 0 {
            score += 1
            // Micro-animation on tap
            withAnimation(.spring(response: 0.15, dampingFraction: 0.5)) {
                tapScale = 0.93
            }
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6).delay(0.1)) {
                tapScale = 1.0
            }
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
