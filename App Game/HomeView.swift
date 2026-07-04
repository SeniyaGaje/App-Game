//
//  HomeView.swift
//  App Game
//
//  Home screen with navigation to game modes and high score display.
//

import SwiftUI

struct HomeView: View {
    @AppStorage("tapFrenzyHighScore") private var tapFrenzyHighScore: Int = 0
    @AppStorage("lightItUpHighScore") private var lightItUpHighScore: Int = 0

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [Color(red: 0.05, green: 0.06, blue: 0.12), Color(red: 0.19, green: 0.16, blue: 0.34), Color(red: 0.05, green: 0.12, blue: 0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                    .overlay(
                        AnimatedStars()
                            .allowsHitTesting(false)
                    )

                Circle()
                    .fill(Color.cyan.opacity(0.16))
                    .frame(width: 260, height: 260)
                    .blur(radius: 40)
                    .offset(x: 150, y: -260)

                Circle()
                    .fill(Color.orange.opacity(0.14))
                    .frame(width: 220, height: 220)
                    .blur(radius: 44)
                    .offset(x: -150, y: 280)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Reaction Games")
                                .font(.system(size: 38, weight: .heavy, design: .rounded))
                                .foregroundStyle(.white)

                            Text("Fast rounds, clean feedback, and friendly game screens built for quick play.")
                                .font(.headline)
                                .foregroundStyle(.white.opacity(0.82))
                                .fixedSize(horizontal: false, vertical: true)

                            HStack(spacing: 10) {
                                labelChip("Tap fast", systemImage: "bolt.fill")
                                labelChip("Track best scores", systemImage: "chart.line.uptrend.xyaxis")
                            }
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .stroke(.white.opacity(0.14), lineWidth: 1)
                        )

                        VStack(alignment: .leading, spacing: 14) {
                            Text("Choose a mode")
                                .font(.headline)
                                .foregroundStyle(.white.opacity(0.9))

                            NavigationLink {
                                TapFrenzyView()
                            } label: {
                                LargeNavButton(title: "Tap Frenzy", subtitle: "Best score: \(tapFrenzyHighScore)  •  Pure speed", color: .green, icon: "bolt.fill")
                            }
                            .buttonStyle(.plain)

                            NavigationLink {
                                LightItUpView()
                            } label: {
                                LargeNavButton(title: "Light It Up", subtitle: "Best score: \(lightItUpHighScore)  •  Pattern timing", color: .blue, icon: "lightbulb.max.fill")
                            }
                            .buttonStyle(.plain)

                            NavigationLink {
                                QuizRushView()
                            } label: {
                                LargeNavButton(title: "Quiz Rush", subtitle: "10 trivia questions  •  Build a streak", color: .orange, icon: "questionmark.circle.fill")
                            }
                            .buttonStyle(.plain)
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Tip")
                                .font(.headline)
                                .foregroundStyle(.white.opacity(0.9))
                            Text("Open each game to find its settings button in the top-right corner.")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.75))
                        }
                        .padding(18)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 20)
                    .padding(.bottom, 28)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private func labelChip(_ title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white.opacity(0.92))
            .padding(.vertical, 9)
            .padding(.horizontal, 12)
            .background(.white.opacity(0.09), in: Capsule())
            .overlay(
                Capsule().stroke(.white.opacity(0.12), lineWidth: 1)
            )
    }
}

private struct LargeNavButton: View {
    let title: String
    let subtitle: String
    let color: Color
    let icon: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(LinearGradient(colors: [color.opacity(0.55), .black.opacity(0.55)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(LinearGradient(colors: [color.opacity(0.9), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2)
                )
                .shadow(color: color.opacity(0.45), radius: 16, x: 0, y: 12)
                .overlay(
                    // Glow highlight
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(color.opacity(0.15))
                        .blur(radius: 20)
                        .offset(y: -20)
                )
            HStack(alignment: .center, spacing: 14) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.25))
                        .frame(width: 54, height: 54)
                        .overlay(Circle().stroke(color.opacity(0.6), lineWidth: 1))
                        .shadow(color: color.opacity(0.5), radius: 8, x: 0, y: 6)
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title2).bold()
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.85))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.white.opacity(0.7))
                    .font(.headline)
            }
            .padding(20)
        }
        .frame(height: 120)
        .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .hoverEffect(.lift)
    }
}

struct SettingsToolbarButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "slider.horizontal.3")
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)
                .padding(10)
                .background(.ultraThinMaterial, in: Circle())
                .overlay(
                    Circle().stroke(.white.opacity(0.18), lineWidth: 1)
                )
        }
        .accessibilityLabel("Game settings")
    }
}

struct SettingsView: View {
    @Binding var roundLength: Int

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [Color(red: 0.05, green: 0.06, blue: 0.12), Color.indigo.opacity(0.42), Color.blue.opacity(0.26)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                Circle()
                    .fill(Color.indigo.opacity(0.22))
                    .frame(width: 220, height: 220)
                    .blur(radius: 42)
                    .offset(x: 130, y: -220)

                Circle()
                    .fill(Color.cyan.opacity(0.16))
                    .frame(width: 200, height: 200)
                    .blur(radius: 40)
                    .offset(x: -130, y: 220)

                Form {
                    Section("Round Length") {
                        Picker("Round Length", selection: $roundLength) {
                            Text("30 s").tag(30)
                            Text("60 s").tag(60)
                            Text("90 s").tag(90)
                        }
                        .pickerStyle(.segmented)
                        .tint(.indigo)

                        Text("This applies to timed games. Choose the pace that feels right for your session.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .headerProminence(.increased)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct AnimatedStars: View {
    @State private var phase: CGFloat = 0
    var body: some View {
        TimelineView(.animation(minimumInterval: 1/30)) { _ in
            Canvas { context, size in
                let starCount = 90
                for i in 0..<starCount {
                    let x = CGFloat(i * 37 % Int(size.width + 200))
                    let y = CGFloat((i * 53) % Int(size.height + 200))
                    let twinkle = (sin((phase + CGFloat(i)) * 0.35) + 1) / 2
                    let radius = 0.6 + twinkle * 1.6
                    let rect = CGRect(x: x.truncatingRemainder(dividingBy: size.width), y: y.truncatingRemainder(dividingBy: size.height), width: radius, height: radius)
                    context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(0.8 * twinkle + 0.1)))
                }
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 6).repeatForever(autoreverses: false)) {
                phase = 20
            }
        }
        .blendMode(.plusLighter)
        .opacity(0.6)
    }
}

#Preview {
    HomeView()
}
