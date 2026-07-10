//
//  App_GameApp.swift
//  App Game
//
//  Created by student6 on 2026-06-27.
//

import SwiftUI
import UserNotifications

@main
struct App_GameApp: App {
    @StateObject private var appState = AppState.shared
    
    init() {
        // Start location tracking immediately so GPS is ready before first game ends
        LocationService.shared.requestPermission()
        LocationService.shared.startUpdating()
        
        // Become the notification delegate so we can handle taps
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}

// MARK: - Notification Delegate

/// Handles foreground display and tap responses for all UNUserNotification events.
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    
    /// Show notification banners even while the app is in the foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
    
    /// Called when the user taps the notification — deep-link to the correct game
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        if let rawMode = userInfo["game"] as? String,
           let mode = GameMode(rawValue: rawMode) {
            DispatchQueue.main.async {
                AppState.shared.pendingGame = mode
            }
        }
        completionHandler()
    }
}
