//
//  ContentView.swift
//  App Game
//
//  Created by student6 on 2026-06-27.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedTab: Int = 0
    
    // Navigation paths for the Home tab's games
    @State private var homePath = NavigationPath()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeTab(path: $homePath)
                .tabItem { Label("Home", systemImage: "gamecontroller") }
                .tag(0)
            
            StatsTab()
                .tabItem { Label("Stats", systemImage: "chart.bar") }
                .tag(1)
            
            MapTab()
                .tabItem { Label("Map", systemImage: "map") }
                .tag(2)
            
            SettingsTab()
                .tabItem { Label("Settings", systemImage: "gear") }
                .tag(3)
        }
        .preferredColorScheme(.dark)
        .tint(.cyan)
        // React to notification deep-links
        .onChange(of: appState.pendingGame) { game in
            guard let game else { return }
            // Switch to Home tab then push the right game
            selectedTab = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                switch game {
                case .tapFrenzy:  homePath.append(HomeDestination.tapFrenzy)
                case .lightItUp:  homePath.append(HomeDestination.lightItUp)
                case .quizRush:   homePath.append(HomeDestination.quizRush)
                }
                appState.pendingGame = nil
            }
        }
    }
}

/// Typed navigation destinations for the Home tab stack
enum HomeDestination: Hashable {
    case tapFrenzy, lightItUp, quizRush
}

#Preview {
    ContentView()
        .environmentObject(AppState.shared)
}
