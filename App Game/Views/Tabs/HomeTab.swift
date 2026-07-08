//
//  HomeView.swift
//  App Game
//
//  Home screen with navigation to game modes and high score display.
//

import SwiftUI

struct HomeTab: View {
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
                    VStack(alignment: .leading, spacing: 24) {

                        // MARK: Hero
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Reaction Games")
                                .font(.system(size: 38, weight: .heavy, design: .rounded))
                                .foregroundStyle(.white)

                            Text("Fast rounds, clean feedback, friendly play.")
                                .font(.headline)
                                .foregroundStyle(.white.opacity(0.78))
                        }
                        .padding(.top, 8)

                        // MARK: Game Cards
                        VStack(spacing: 14) {
                            NavigationLink {
                                TapFrenzyView()
                            } label: {
                                LargeNavButton(
                                    title: "Tap Frenzy",
                                    subtitle: "Best: \(tapFrenzyHighScore)  •  Pure speed",
                                    color: .green,
                                    icon: "bolt.fill"
                                )
                            }
                            .buttonStyle(.plain)

                            NavigationLink {
                                LightItUpView()
                            } label: {
                                LargeNavButton(
                                    title: "Light It Up",
                                    subtitle: "Best: \(lightItUpHighScore)  •  Pattern timing",
                                    color: .cyan,
                                    icon: "lightbulb.max.fill"
                                )
                            }
                            .buttonStyle(.plain)

                            NavigationLink {
                                QuizRushView()
                            } label: {
                                LargeNavButton(
                                    title: "Quiz Rush",
                                    subtitle: "10 trivia questions  •  Build a streak",
                                    color: .orange,
                                    icon: "questionmark.circle.fill"
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 32)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .preferredColorScheme(.dark)
        }
    }
}

private struct LargeNavButton: View {
    let title: String
    let subtitle: String
    let color: Color
    let icon: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [color.opacity(0.65), color.opacity(0.25), .black.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(
                            LinearGradient(colors: [color.opacity(0.9), color.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 1.5
                        )
                )
                .shadow(color: color.opacity(0.5), radius: 20, x: 0, y: 14)

            HStack(alignment: .center, spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.3))
                        .frame(width: 58, height: 58)
                        .overlay(Circle().stroke(color.opacity(0.7), lineWidth: 1.5))
                        .shadow(color: color.opacity(0.6), radius: 10, x: 0, y: 6)
                    Image(systemName: icon)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.white.opacity(0.6))
                    .font(.headline)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 22)
        }
        .frame(height: 110)
        .contentShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
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
                .background(Color(red: 0.12, green: 0.14, blue: 0.24), in: Circle())
                .overlay(
                    Circle().stroke(.white.opacity(0.2), lineWidth: 1)
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
                            Text("40 s").tag(40)
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
    HomeTab()
}
