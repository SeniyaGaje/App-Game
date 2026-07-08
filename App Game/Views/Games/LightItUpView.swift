//
//  LightItUpView.swift
//  App Game
//
//  Week 2 mode: cards light up; tap them before they go dark.
//
//  Timer system:
//  - One continuous 40-second round (10s per level).
//  - Level progresses automatically based on elapsed time.
//  - 4 lives — missed card costs a life. 0 lives = Game Over.
//  - Surviving the full 40 seconds = Round Complete.
//

import SwiftUI

struct LightItUpView: View {
    @AppStorage("lightItUpHighScore") private var highScore: Int = 0
    @AppStorage("playerName") private var playerName: String = "Player 1"
    let roundLength: Int = 60 // Hardcoded to exactly 60s (15s per level)

    // MARK: - State
    @State private var cards: [GameCard] = []
    @State private var score: Int = 0
    @State private var lives: Int = 5
    @State private var timeLeft: Int = 60
    @State private var isPlaying: Bool = false
    @State private var isGameOver: Bool = false
    @State private var isRoundComplete: Bool = false
    @State private var level: LightLevel = .level1

    @State private var roundTimer: Timer?

    /// Incremented every time the game resets, level changes, or a tile is tapped.
    /// Used to invalidate stale DispatchQueue.main.asyncAfter callbacks.
    @State private var tickGeneration: Int = 0

    @State private var showLevelFlash: Bool = false
    @State private var levelFlashText: String = ""
    @State private var shakeLives: Bool = false

    var body: some View {
        ZStack {
            // Background gradient — shifts colour per level
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.06, blue: 0.12),
                    level.glowColor.opacity(0.18),
                    Color.blue.opacity(0.14)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.6), value: level)

            Circle()
                .fill(level.glowColor.opacity(0.20))
                .frame(width: 300, height: 300)
                .blur(radius: 52)
                .offset(x: 140, y: -260)
                .animation(.easeInOut(duration: 0.6), value: level)

            Circle()
                .fill(Color.blue.opacity(0.10))
                .frame(width: 220, height: 220)
                .blur(radius: 44)
                .offset(x: -140, y: 320)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {

                    // MARK: Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Light It Up")
                            .font(.system(size: 34, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                        Text(headerSubtitle)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.white.opacity(0.72))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(.black.opacity(0.35),
                                in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(level.glowColor.opacity(0.3), lineWidth: 1)
                    )

                    // MARK: Stats row (compact, 4 columns)
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4),
                        spacing: 8
                    ) {
                        StatBlock(title: "Score", value: "\(score)", compact: true)
                        StatBlock(title: "Best",  value: "\(highScore)", compact: true)
                        StatBlock(title: "Level", value: "\(level.rawValue)", compact: true)
                        StatBlock(title: "Time",  value: "\(timeLeft)s",
                                  isWarning: isPlaying && timeLeft <= 10, compact: true)
                    }

                    // MARK: Lives
                    livesRow

                    // MARK: Level progress bar
                    if isPlaying {
                        levelProgressBar
                    }

                    // MARK: Game Grid + Controls
                    VStack(spacing: 16) {
                        // The grid — uses indices to guarantee rendering all slots
                        LazyVGrid(columns: level.gridColumns, spacing: 10) {
                            ForEach(cards.indices, id: \.self) { index in
                                CardView(isLit: cards[index].isLit, color: level.glowColor)
                                    .onTapGesture { handleTap(on: index) }
                            }
                        }
                        .padding(14)
                        .background(.black.opacity(0.45),
                                    in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(level.glowColor.opacity(0.25), lineWidth: 1.5)
                        )

                        // Controls
                        HStack(spacing: 12) {
                            Button(controlButtonLabel) {
                                resetGame(start: true)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(level.glowColor.opacity(0.9))
                            .font(.headline)

                            if isPlaying {
                                Button("Stop") { resetGame(start: false) }
                                    .buttonStyle(.bordered)
                                    .tint(.white.opacity(0.8))
                            }
                        }
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity)
                    .background(.black.opacity(0.35),
                                in: RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(.white.opacity(0.12), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
            }

            // MARK: Level-up flash overlay
            if showLevelFlash {
                VStack {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(level.glowColor)
                        Text(levelFlashText)
                            .font(.system(size: 18, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(.black.opacity(0.85), in: Capsule())
                    .overlay(Capsule().stroke(level.glowColor, lineWidth: 2))
                    .shadow(color: level.glowColor.opacity(0.5), radius: 10)
                    .padding(.top, 50)
                    
                    Spacer() // Pushes it to the top so it doesn't block the grid!
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .allowsHitTesting(false)
                .zIndex(100)
            }

            // MARK: Game Over overlay
            if isGameOver {
                gameOverOverlay
            }

            // MARK: Round Complete overlay
            if isRoundComplete {
                roundCompleteOverlay
            }
        }
        .navigationTitle("Light It Up")
        .navigationBarTitleDisplayMode(.inline)
        // No Settings Toolbar item here per user request!
        .onAppear {
            level = .level1
            timeLeft = roundLength
            if cards.isEmpty { rebuildCards() }
        }
        .onDisappear {
            isPlaying = false
            stopAllTimers()
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Computed Helpers

    private var headerSubtitle: String {
        if isGameOver      { return "Game over! Tap Play Again to retry." }
        if isRoundComplete { return "Round complete! Tap Play Again." }
        if isPlaying       { return "Stay sharp — tap the lit cards!" }
        return "Tap lit cards before they fade. Don't miss!"
    }

    private var controlButtonLabel: String {
        if isPlaying { return "Restart" }
        if isGameOver || isRoundComplete { return "Play Again" }
        return "Start"
    }

    // MARK: - Sub-views

    private var livesRow: some View {
        HStack(spacing: 0) {
            Text("LIVES")
                .font(.system(size: 10, weight: .semibold))
                .tracking(1.2)
                .foregroundStyle(.white.opacity(0.55))
            Spacer()
            HStack(spacing: 6) {
                ForEach(0..<5) { i in
                    Image(systemName: i < lives ? "heart.fill" : "heart")
                        .font(.system(size: 20))
                        .foregroundStyle(i < lives ? Color.red : Color.white.opacity(0.25))
                        .scaleEffect(shakeLives && i == lives ? 1.4 : 1.0)
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(.black.opacity(0.35),
                    in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(.white.opacity(0.12), lineWidth: 1)
        )
    }

    private var levelProgressBar: some View {
        let totalProgress = 1.0 - (Double(timeLeft) / Double(max(1, roundLength)))
        let rightLabel = level == .level4 ? "Final stage" : "Round progress"

        return VStack(spacing: 6) {
            HStack {
                Text("L\(level.rawValue)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(level.glowColor)
                Spacer()
                Text(rightLabel)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.45))
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(level.glowColor)
                        .frame(width: geo.size.width * totalProgress, height: 6)
                        .animation(.easeInOut(duration: 0.9), value: timeLeft)
                }
            }
            .frame(height: 6)
        }
        .padding(.horizontal, 4)
    }

    private var gameOverOverlay: some View {
        ZStack {
            Color.black.opacity(0.65).ignoresSafeArea()
            VStack(spacing: 18) {
                Image(systemName: "heart.slash.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(.red)

                Text("Game Over")
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)

                VStack(spacing: 6) {
                    Text("Score: \(score)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(score >= highScore ? "🏆 New best!" : "Best: \(highScore)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(score >= highScore ? .yellow : .white.opacity(0.65))
                    Text("Survived until Level \(level.rawValue)")
                        .font(.subheadline)
                        .foregroundStyle(level.glowColor)
                }

                Button("Play Again") { resetGame(start: true) }
                    .buttonStyle(.borderedProminent)
                    .tint(.red.opacity(0.85))
                    .font(.headline)
                    .controlSize(.large)
                
                ShareLink(item: "I survived to Level \(level.rawValue) with \(score) points on Light It Up — beat that!")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                    .padding(.top, 4)
            }
            .padding(32)
            .background(.black.opacity(0.45),
                        in: RoundedRectangle(cornerRadius: 28))
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color.red.opacity(0.4), lineWidth: 1.5)
            )
            .padding(.horizontal, 28)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.92)))
    }

    private var roundCompleteOverlay: some View {
        ZStack {
            Color.black.opacity(0.65).ignoresSafeArea()
            VStack(spacing: 18) {
                Image(systemName: "star.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(.yellow)
                    .shadow(color: .yellow.opacity(0.6), radius: 10)

                Text("Round Complete!")
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)

                VStack(spacing: 6) {
                    Text("Score: \(score)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(score >= highScore ? "🏆 New best!" : "Best: \(highScore)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(score >= highScore ? .yellow : .white.opacity(0.65))
                    Text("Cleared all levels!")
                        .font(.subheadline)
                        .foregroundStyle(.green)
                }

                Button("Play Again") { resetGame(start: true) }
                    .buttonStyle(.borderedProminent)
                    .tint(.green.opacity(0.85))
                    .font(.headline)
                    .controlSize(.large)
                
                ShareLink(item: "I beat Light It Up with \(score) points — beat that!")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                    .padding(.top, 4)
            }
            .padding(32)
            .background(.black.opacity(0.45),
                        in: RoundedRectangle(cornerRadius: 28))
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color.yellow.opacity(0.5), lineWidth: 1.5)
            )
            .padding(.horizontal, 28)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.92)))
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Game Flow
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private func resetGame(start: Bool) {
        stopAllTimers()
        tickGeneration += 1          // invalidate all pending asyncAfter callbacks
        score = 0
        lives = 5
        level = .level1
        timeLeft = roundLength
        isGameOver = false
        isRoundComplete = false
        rebuildCards()
        if start {
            isPlaying = true
            startRoundTimer()
            tickLights() // kick off the pure async loop!
        } else {
            isPlaying = false
        }
    }

    private func startRoundTimer() {
        roundTimer?.invalidate()
        roundTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            guard isPlaying else { return }
            if timeLeft > 0 {
                timeLeft -= 1
                checkLevelProgress()
            }
            if timeLeft == 0 {
                // Timer finished! You survived the full round.
                endGame(complete: true)
            }
        }
    }

    private func checkLevelProgress() {
        let elapsed = roundLength - timeLeft
        let expectedLevel = LightLevel.level(forElapsed: elapsed, totalDuration: roundLength)
        
        if expectedLevel != level {
            advanceLevel(to: expectedLevel)
        }
    }

    private func stopAllTimers() {
        roundTimer?.invalidate(); roundTimer = nil
        tickGeneration += 1 // this stops the async loop
    }

    private func endGame(complete: Bool) {
        isPlaying = false
        stopAllTimers()
        clearLit()
        if score > highScore { highScore = score }
        StatsVM.shared.addSession(mode: .lightItUp, score: score, playerName: playerName)
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            if complete { isRoundComplete = true } else { isGameOver = true }
        }
    }

    // MARK: - Level Advancement

    private func advanceLevel(to nextLevel: LightLevel) {
        level = nextLevel
        rebuildCards()
        showLevelUpFlash(for: nextLevel)
        // Note: the existing async loop continues and naturally inherits the new litWindow on its next cycle.
    }

    private func showLevelUpFlash(for lvl: LightLevel) {
        levelFlashText = "Level \(lvl.rawValue)!"
        withAnimation(.easeInOut(duration: 0.25)) { showLevelFlash = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut(duration: 0.3)) { showLevelFlash = false }
        }
    }

    // MARK: - Lighting Logic (Pure Async Loop - No Timer Race Conditions)

    private func tickLights() {
        guard isPlaying else { return }

        // 1) Clear previous
        clearLit()

        // 2) Light new cards
        let indices = randomUniqueIndices(count: level.litCount, upperBound: cards.count)
        for idx in indices {
            cards[idx].isLit = true
        }

        // 3) Schedule auto-dim based on current level's window
        tickGeneration += 1
        let gen = tickGeneration
        let currentLitWindow = level.litWindow
        
        DispatchQueue.main.asyncAfter(deadline: .now() + currentLitWindow) {
            guard gen == tickGeneration, isPlaying else { return }
            
            // Check if they missed it! (If a card is still lit when time runs out, it's a miss)
            let missedCount = indices.filter { $0 < cards.count && cards[$0].isLit }.count
            if missedCount > 0 {
                loseLife(count: missedCount)
            }
            
            // Immediately loop to the next set of cards
            tickLights()
        }
    }

    private func clearLit() {
        for i in cards.indices { cards[i].isLit = false }
    }

    private func rebuildCards() {
        cards = (0..<level.cardCount).map { _ in GameCard() }
    }

    private func randomUniqueIndices(count: Int, upperBound: Int) -> [Int] {
        guard count > 0, upperBound > 0 else { return [] }
        var pool = Array(0..<upperBound)
        pool.shuffle()
        return Array(pool.prefix(count))
    }

    // MARK: - Lives

    private func loseLife(count: Int = 1) {
        lives = max(0, lives - count)
        withAnimation(.spring(response: 0.2, dampingFraction: 0.3)) { shakeLives = true }
        withAnimation(.spring(response: 0.2, dampingFraction: 0.3).delay(0.3)) { shakeLives = false }
        if lives == 0 {
            endGame(complete: false)
        }
    }

    // MARK: - Input

    private func handleTap(on index: Int) {
        guard isPlaying, index < cards.count else { return }
        
        if cards[index].isLit {
            score += 1
            cards[index].isLit = false
            
            // If there are no more lit cards (e.g. Level 4 has 2 lit cards), spawn the next set instantly!
            if cards.filter(\.isLit).count == 0 {
                tickLights() // This automatically increments tickGeneration, cancelling the previous auto-dim!
            }
        } else {
            loseLife()
        }
    }
}

// MARK: - Card View

private struct CardView: View {
    let isLit: Bool
    let color: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    isLit
                        ? color.opacity(0.88)
                        : .black.opacity(0.45)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isLit ? color : Color.white.opacity(0.15),
                            lineWidth: isLit ? 2.5 : 1
                        )
                )
                .shadow(color: isLit ? color.opacity(0.7) : .clear, radius: isLit ? 12 : 0)
                .scaleEffect(isLit ? 1.06 : 1.0)
                .animation(.spring(response: 0.22, dampingFraction: 0.72), value: isLit)

            if isLit {
                Image(systemName: "bolt.fill")
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                    .shadow(color: .white.opacity(0.55), radius: 4)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(height: 72)
        .contentShape(Rectangle())   // makes full card area tappable
    }
}

#Preview {
    NavigationStack {
        LightItUpView()
    }
}
