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

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.black, Color.gray.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("Tap Frenzy")
                    .font(.largeTitle).bold()
                    .foregroundStyle(.white)

                HStack(spacing: 32) {
                    StatBlock(title: "Score", value: "\(score)")
                    StatBlock(title: "Best", value: "\(highScore)")
                    StatBlock(title: "Time", value: "\(timeLeft)s", isWarning: isPlaying && timeLeft <= 5)
                }

                Spacer(minLength: 8)

                Button(action: handleTap) {
                    ZStack {
                        Circle()
                            .fill(isPlaying ? Color.green : Color.gray.opacity(0.3))
                            .frame(width: 240, height: 240)
                            .shadow(color: isPlaying ? .green.opacity(0.6) : .black.opacity(0.2), radius: 18, x: 0, y: 10)
                        Text(isPlaying ? "Tap!" : "Start")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .scaleEffect(isPlaying ? 1.02 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: isPlaying)
                }
                .buttonStyle(.plain)
                .disabled(isPlaying && timeLeft == 0)

                Button(isPlaying ? "Restart" : "Reset") {
                    resetGame(start: isPlaying)
                }
                .buttonStyle(.borderedProminent)

                Spacer()
            }
            .padding()
            .onAppear { timeLeft = roundLength }
            .onDisappear { stopTimer() }
        }
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
    TapFrenzyView()
}
