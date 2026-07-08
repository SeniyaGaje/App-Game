import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            print("Notifications granted: \(granted)")
        }
    }
    
    func scheduleDailyChallenge(at time: Date, isEnabled: Bool) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        guard isEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Daily Challenge!"
        content.body = "It's time to elevate your focus. Can you beat your high score today?"
        content.sound = .default
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_challenge", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}
