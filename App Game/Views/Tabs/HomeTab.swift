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
    @AppStorage("playerAvatar") private var playerAvatar: String = "person.crop.circle.fill"
    @AppStorage("playerProfileImageData") private var profileImageData: Data = Data()
    
    @Binding var path: NavigationPath
    @State private var showProfile = false

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Color(red: 0.04, green: 0.04, blue: 0.08)
                    .ignoresSafeArea()
                
                // Modern blurred blobs
                Circle()
                    .fill(Color.purple.opacity(0.35))
                    .frame(width: 350, height: 350)
                    .blur(radius: 80)
                    .offset(x: -150, y: -250)

                Circle()
                    .fill(Color.cyan.opacity(0.35))
                    .frame(width: 350, height: 350)
                    .blur(radius: 80)
                    .offset(x: 150, y: 250)
                
                Circle()
                    .fill(Color.orange.opacity(0.25))
                    .frame(width: 250, height: 250)
                    .blur(radius: 60)
                    .offset(x: 100, y: -50)

                AnimatedStars()
                    .allowsHitTesting(false)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {

                        // MARK: Hero
                        VStack(alignment: .center, spacing: 6) {
                            ZStack {
                                Text("Gamify")
                                    .font(.system(size: 42, weight: .black, design: .rounded))
                                    .foregroundStyle(
                                        LinearGradient(colors: [.white, .white.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    )
                                    .shadow(color: .purple.opacity(0.4), radius: 20)

                                HStack {
                                    Spacer()

                                    Button {
                                        showProfile = true
                                    } label: {
                                        ProfileAvatarImage(
                                            imageData: profileImageData,
                                            systemName: playerAvatar,
                                            size: 48
                                        )
                                    }
                                    .accessibilityLabel("Open profile")
                                }
                            }
                            .frame(maxWidth: .infinity)

                            Text("Elevate your focus.\nChallenge your reflexes.")
                                .font(.title3.weight(.medium))
                                .foregroundStyle(.white.opacity(0.6))
                                .lineSpacing(4)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 16)
                        .padding(.bottom, 8)

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
            .fullScreenCover(isPresented: $showProfile) {
                ProfileView()
            }
            .navigationDestination(for: HomeDestination.self) { destination in
                switch destination {
                case .tapFrenzy: TapFrenzyView()
                case .lightItUp: LightItUpView()
                case .quizRush:  QuizRushView()
                }
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
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(.black.opacity(0.35))
                .background(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(color.opacity(0.15))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .stroke(LinearGradient(colors: [.white.opacity(0.3), .white.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5)
                )
                .shadow(color: color.opacity(0.2), radius: 25, x: 0, y: 10)

            HStack(alignment: .center, spacing: 18) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(colors: [color.opacity(0.8), color.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 60, height: 60)
                        .shadow(color: color.opacity(0.6), radius: 12, x: 0, y: 6)
                        .overlay(Circle().stroke(.white.opacity(0.4), lineWidth: 1))

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
                            Text("15 s").tag(15)
                            Text("30 s").tag(30)
                            Text("40 s").tag(40)
                            Text("60 s").tag(60)
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
    HomeTab(path: .constant(NavigationPath()))
}
