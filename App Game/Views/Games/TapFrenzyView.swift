import SwiftUI

struct TapFrenzyView: View {
    @AppStorage("tapFrenzyHighScore") private var highScore: Int = 0
    @AppStorage("roundLength") private var roundLength: Int = 60
    @AppStorage("playerName") private var playerName: String = "Player 1"

    @State private var score: Int = 0
    @State private var timeLeft: Int = 60
    @State private var isPlaying: Bool = false
    @State private var timer: Timer?
    @State private var showSettings: Bool = false
    @State private var tapScale: CGFloat = 1.0
    @State private var targetOffset: CGSize = .zero
    
    // The button shrinks as your score goes up, down to a minimum of 20% original size
    private var dynamicScale: CGFloat {
        if !isPlaying { return 1.0 }
        let scale = 1.0 - (CGFloat(score) * 0.02)
        return max(0.2, scale)
    }

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
                VStack(spacing: 12) {

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
                    .padding(14)
                    .background(.black.opacity(0.35), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(.white.opacity(0.15), lineWidth: 1)
                    )

                    // Stats
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        StatBlock(title: "Score", value: "\(score)", compact: true)
                        StatBlock(title: "Best", value: "\(highScore)", compact: true)
                        StatBlock(title: "Time", value: "\(timeLeft)s", isWarning: isPlaying && timeLeft <= 5, compact: true)
                    }

                    // Tap Circle
                    VStack(spacing: 16) {
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
                                                colors: [.black.opacity(0.3), .black.opacity(0.45)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                              )
                                    )
                                    .frame(width: 258, height: 258)
                                    .shadow(color: isPlaying ? Color.green.opacity(0.55) : Color.black.opacity(0.45), radius: isPlaying ? 28 : 16, x: 0, y: 12)

                                VStack(spacing: 6) {
                                    if isPlaying {
                                        Text("TAP")
                                            .font(.system(size: 44, weight: .heavy, design: .rounded))
                                            .foregroundStyle(.white)
                                        Text("Every tap counts")
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(.white.opacity(0.85))
                                    } else {
                                        Text("START")
                                            .font(.system(size: 44, weight: .heavy, design: .rounded))
                                            .foregroundStyle(Color.green)
                                        Text("Begin a fast round")
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(Color.white.opacity(0.55))
                                    }
                                }
                                .id(isPlaying) // forces clear transition
                            }
                            .scaleEffect(tapScale * dynamicScale)
                            .animation(.easeOut(duration: 0.2), value: dynamicScale)
                            .offset(targetOffset)
                        }
                        .buttonStyle(.plain)
                        .disabled(isPlaying && timeLeft == 0)
                        .frame(height: 280) // Reduced space to fit smaller screens

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
                            if !isPlaying && score > 0 {
                                ShareLink(item: "I just scored \(score) on Tap Frenzy — beat that!") {
                                    Label("Share", systemImage: "square.and.arrow.up")
                                }
                                .buttonStyle(.bordered)
                                .tint(.cyan.opacity(0.8))
                            }
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity)
                    .background(.black.opacity(0.35), in: RoundedRectangle(cornerRadius: 32, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .stroke(.white.opacity(0.15), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 18)
                .padding(.top, 18)
                .padding(.bottom, 100) // Extra padding to clear the Tab Bar
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
            
            // Randomize position to make it harder, but keep it strictly inside the modal
            withAnimation(.interpolatingSpring(stiffness: 100, damping: 10)) {
                // The modal inner width is roughly 300 points. 
                let currentSize = 266.0 * dynamicScale
                let maxSafeOffset = max(0, (300.0 - currentSize) / 2.0 - 15.0)
                let range = min(maxSafeOffset, 80.0)
                
                targetOffset = CGSize(
                    width: CGFloat.random(in: -range...range),
                    height: CGFloat.random(in: -range...range)
                )
            }
            
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
        withAnimation(.spring()) {
            targetOffset = .zero
        }
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
                withAnimation(.spring()) {
                    targetOffset = .zero
                }
                if score > highScore { highScore = score }
                StatsVM.shared.addSession(mode: .tapFrenzy, score: score, playerName: playerName)
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
