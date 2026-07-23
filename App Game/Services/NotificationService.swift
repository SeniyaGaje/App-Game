import Foundation
import UserNotifications

class NotificationService: NSObject {
    static let shared = NotificationService()
    
    private let notificationIdPrefix = "daily_challenge_"
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            print("Notifications granted: \(granted)")
        }
    }
    
    // Parameters
    func scheduleDailyChallenge(at time: Date, isEnabled: Bool, game: GameMode?) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        guard isEnabled else { return }
        
        if let game {
            // Repeating daily notification
            scheduleNotification(for: game, at: time, weekday: nil)
        } else {
            // Random — schedule one notification per game on a rotating weekday pattern
            let assignments: [(GameMode, [Int])] = [
                (.tapFrenzy, [2, 5]),   // Monday, Thursday
                (.lightItUp, [3, 6]),   // Tuesday, Friday
                (.quizRush,  [4, 7, 1]) // Wednesday, Saturday, Sunday
            ]
            for (mode, weekdays) in assignments {
                for weekday in weekdays {
                    scheduleNotification(for: mode, at: time, weekday: weekday)
                }
            }
        }
    }
    
    
    private func scheduleNotification(for game: GameMode, at time: Date, weekday: Int?) {
        let content = UNMutableNotificationContent()
        content.sound = .default
        content.userInfo = ["game": game.rawValue]
        
        switch game {
        case .tapFrenzy:
            content.title = "⚡ Tap Frenzy Challenge!"
            content.body = "How fast can you tap today? Your best is waiting to be broken."
        case .lightItUp:
            content.title = "💡 Light It Up Challenge!"
            content.body = "The lights are flickering — can you keep up your streak today?"
        case .quizRush:
            content.title = "🧠 Quiz Rush Challenge!"
            content.body = "10 questions. Beat your streak. Your daily brain workout is ready."
        }
        
        var components = Calendar.current.dateComponents([.hour, .minute], from: time)
        if let weekday { components.weekday = weekday }
        
        let identifier = weekday != nil
            ? "\(notificationIdPrefix)\(game.rawValue)_\(weekday!)"
            : "\(notificationIdPrefix)\(game.rawValue)"
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
