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

    var body: some View {
        NavigationStack {
            ZStack {
                // Dark gradient background
                LinearGradient(colors: [Color.black, Color.gray.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    Text("Reaction Games")
                        .font(.system(size: 36, weight: .heavy))
                        .foregroundStyle(.white)
                        .padding(.top, 24)

                    VStack(spacing: 16) {
                        NavigationLink {
                            TapFrenzyView()
                        } label: {
                            LargeNavButton(title: "Tap Frenzy", subtitle: "Best: \(tapFrenzyHighScore)", color: .green)
                        }

                        NavigationLink {
                            LightItUpView()
                        } label: {
                            LargeNavButton(title: "Light It Up", subtitle: "Best: \(lightItUpHighScore)", color: .blue)
                        }
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
                            .foregroundStyle(.white)
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

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(colors: [color.opacity(0.6), .black.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(color.opacity(0.8), lineWidth: 2)
                )
                .shadow(color: color.opacity(0.5), radius: 10, x: 0, y: 8)
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.title).bold()
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(20)
        }
        .frame(height: 120)
    }
}

private struct SettingsView: View {
    @Binding var roundLength: Int

    var body: some View {
        NavigationStack {
            Form {
                Section("Round Length") {
                    Picker("Round Length", selection: $roundLength) {
                        Text("30 seconds").tag(30)
                        Text("60 seconds").tag(60)
                        Text("90 seconds").tag(90)
                    }
                    .pickerStyle(.inline)
                }
                .headerProminence(.increased)
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    HomeView()
}
