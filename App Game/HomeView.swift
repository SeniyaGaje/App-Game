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
    @AppStorage("roundLength") private var roundLength: Int = 60 // settings: 30, 60, 90

    @State private var showSettings: Bool = false
    @State private var animateBG: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Animated cosmic gradient background
                LinearGradient(colors: [Color.black, Color.purple.opacity(0.5), Color.blue.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                    .overlay(
                        // Subtle animated particles
                        AnimatedStars()
                            .allowsHitTesting(false)
                    )

                VStack(spacing: 24) {
                    // Title with glass effect
                    Text("Reaction Games")
                        .font(.system(size: 36, weight: .heavy))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(LinearGradient(colors: [.white.opacity(0.6), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                                )
                        )
                        .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 10)
                        .padding(.top, 24)

                    VStack(spacing: 16) {
                        NavigationLink {
                            TapFrenzyView()
                        } label: {
                            LargeNavButton(title: "Tap Frenzy", subtitle: "Best: \(tapFrenzyHighScore)", color: .green, icon: "bolt.fill")
                        }
                        .buttonStyle(.plain)

                        NavigationLink {
                            LightItUpView()
                        } label: {
                            LargeNavButton(title: "Light It Up", subtitle: "Best: \(lightItUpHighScore)", color: .blue, icon: "lightbulb.max.fill")
                        }
                        .buttonStyle(.plain)

                        NavigationLink {
                            QuizRushView()
                        } label: {
                            LargeNavButton(title: "Quiz Rush", subtitle: "Live Trivia", color: .orange, icon: "questionmark.circle.fill")
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal)

                    Spacer()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings.toggle()
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(8)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(roundLength: $roundLength)
            }
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

private struct SettingsView: View {
    @Binding var roundLength: Int

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [Color.black, Color.indigo.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                Form {
                    Section("Round Length") {
                        Picker("Round Length", selection: $roundLength) {
                            Text("30 s").tag(30)
                            Text("60 s").tag(60)
                            Text("90 s").tag(90)
                        }
                        .pickerStyle(.segmented)
                        .tint(.indigo)
                    }
                    .headerProminence(.increased)
                }
            }
            .navigationTitle("Settings")
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
