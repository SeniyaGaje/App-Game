//
//  ContentView.swift
//  App Game
//
//  Created by student6 on 2026-06-27.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeTab()
                .tabItem {
                    Label("Home", systemImage: "gamecontroller")
                }
            
            StatsTab()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar")
                }
            
            MapTab()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
            
            SettingsTab()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .preferredColorScheme(.dark)
        .tint(.cyan)
    }
}

#Preview {
    ContentView()
}
