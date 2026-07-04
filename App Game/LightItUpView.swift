//
//  LightItUpView.swift
//  App Game
//
//  Week 2 mode: cards light up; tap them before they go dark.
//

import SwiftUI

struct LightItUpView: View {
    @AppStorage("lightItUpHighScore") private var highScore: Int = 0
    @AppStorage("roundLength") private var roundLength: Int = 60

    @State private var cards: [GameCard] = []
    @State private var score: Int = 0
    @State private var timeLeft: Int = 60
    @State private var isPlaying: Bool = false
    @State private var level: LightLevel = .level1

    @State private var roundTimer: Timer?
    @State private var lightTimer: Timer?

    @State private var showLevelFlash: Bool = false
    @State private var showSettings: Bool = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.05, green: 0.06, blue: 0.12), Color.blue.opacity(0.22), Color.cyan.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            Circle()
                .fill(level.glowColor.opacity(0.16))
                .frame(width: 260, height: 260)
                .blur(radius: 42)
                .offset(x: 140, y: -240)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Light It Up")
                            .font(.system(size: 36, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                        Text("Tap the lit cards before they fade out.")
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.82))
                        Text(isPlaying ? "Stay sharp and build your score." : "A fresh grid is ready when you are.")
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

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        StatBlock(title: "Score", value: "\(score)")
                        StatBlock(title: "Best", value: "\(highScore)")
                        StatBlock(title: "Level", value: "\(level.rawValue)")
                        StatBlock(title: "Time", value: "\(timeLeft)s", isWarning: isPlaying && timeLeft <= 5)
                    }

                    VStack(spacing: 14) {
                        Text("Use the settings button in the top-right corner to change the round length.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.76))
                            .multilineTextAlignment(.center)

                        LazyVGrid(columns: level.gridColumns, spacing: 12) {
                            ForEach(Array(cards.enumerated()), id: \.element) { index, card in
                                CardView(isLit: card.isLit, color: level.glowColor)
                                    .onTapGesture { handleTap(on: index) }
                                    .animation(.easeInOut(duration: 0.15), value: card.isLit)
                            }
                        }
                        .padding(16)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .stroke(.white.opacity(0.12), lineWidth: 1)
                        )

                        HStack(spacing: 12) {
                            Button(isPlaying ? "Restart" : "Start") { resetGame(start: true) }
                                .buttonStyle(.borderedProminent)

                            if isPlaying {
                                Button("Stop") { resetGame(start: false) }
                                    .buttonStyle(.bordered)
                            }
                        }
                    }
                    .padding(18)
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

            if showLevelFlash {
                Color.white.opacity(0.25)
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
        }
        .navigationTitle("Light It Up")
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
            configureLevel(for: 0)
            if cards.isEmpty {
                rebuildCards()
            }
        }
        .onChange(of: roundLength) { newValue in
            if !isPlaying {
                timeLeft = newValue
            }
        }
        .onDisappear { stopAllTimers() }
    }

    // MARK: - Game Flow

    private func resetGame(start: Bool) {
        score = 0
        timeLeft = roundLength
        level = .level1
        rebuildCards()
        clearLit()
        if start {
            isPlaying = true
            startRoundTimer()
            startLightTimer()
        } else {
            isPlaying = false
            stopAllTimers()
        }
    }

    private func startRoundTimer() {
        roundTimer?.invalidate()
        roundTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeLeft > 0 { timeLeft -= 1 }
            updateLevelForElapsed()
            if timeLeft == 0 {
                isPlaying = false
                stopAllTimers()
                if score > highScore { highScore = score }
            }
        }
    }

    private func startLightTimer() {
        lightTimer?.invalidate()
        lightTimer = Timer.scheduledTimer(withTimeInterval: max(0.2, level.litWindow), repeats: true) { _ in
            tickLights()
        }
    }

    private func stopAllTimers() {
        roundTimer?.invalidate(); roundTimer = nil
        lightTimer?.invalidate(); lightTimer = nil
    }

    // MARK: - Level & Cards

    private func updateLevelForElapsed() {
        let elapsed = roundLength - timeLeft
        configureLevel(for: elapsed)
    }

    private func configureLevel(for elapsed: Int) {
        let newLevel: LightLevel
        switch elapsed {
        case 0..<15: newLevel = .level1
        case 15..<30: newLevel = .level2
        case 30..<45: newLevel = .level3
        default: newLevel = .level4
        }
        if newLevel != level {
            level = newLevel
            rebuildCards()
            flashLevel()
            // Restart light timer with new cadence
            if isPlaying { startLightTimer() }
        }
    }

    private func rebuildCards() {
        cards = Array(repeating: GameCard(), count: level.cardCount)
    }

    private func flashLevel() {
        withAnimation(.easeInOut(duration: 0.25)) { showLevelFlash = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation(.easeInOut(duration: 0.25)) { showLevelFlash = false }
        }
    }

    // MARK: - Lighting Logic

    private func tickLights() {
        // Apply missed penalty for any lit cards that weren't tapped
        let missedCount = cards.filter { $0.isLit }.count
        if missedCount > 0 {
            score = max(0, score - missedCount) // -1 per missed
        }

        // Clear previous lit state
        clearLit()

        // Choose random indices to light
        let indices = randomUniqueIndices(count: level.litCount, upperBound: cards.count)
        for idx in indices {
            cards[idx].isLit = true
        }

        // Schedule auto-dim after the window (enforces miss penalty next tick if not tapped)
        DispatchQueue.main.asyncAfter(deadline: .now() + level.litWindow) {
            for i in indices { if i < cards.count { cards[i].isLit = false } }
        }
    }

    private func clearLit() {
        for i in cards.indices { cards[i].isLit = false }
    }

    private func randomUniqueIndices(count: Int, upperBound: Int) -> [Int] {
        guard count > 0, upperBound > 0 else { return [] }
        var indices = Array(0..<upperBound)
        indices.shuffle()
        return Array(indices.prefix(count))
    }

    // MARK: - Input

    private func handleTap(on index: Int) {
        guard index < cards.count else { return }
        if cards[index].isLit {
            score += 1
            cards[index].isLit = false
        } else {
            score = max(0, score - 1)
        }
    }
}

private struct CardView: View {
    let isLit: Bool
    let color: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(isLit ? color.opacity(0.9) : Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isLit ? color : Color.white.opacity(0.2), lineWidth: isLit ? 3 : 1)
                )
                .shadow(color: isLit ? color.opacity(0.7) : .clear, radius: isLit ? 12 : 0)
                .scaleEffect(isLit ? 1.05 : 1.0)
                .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isLit)

            if isLit {
                Image(systemName: "bolt.fill")
                    .font(.title)
                    .foregroundStyle(.white)
            }
        }
        .frame(height: 80)
    }
}

#Preview {
    NavigationStack {
        LightItUpView()
    }
}
