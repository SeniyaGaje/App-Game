import Foundation
import CoreLocation
import Combine
import SwiftUI

class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationService()
    private let manager = CLLocationManager()
    
    @Published var currentLocation: CLLocationCoordinate2D?
    
    // Persist last known location so it survives app relaunches
    private let latKey = "lastKnownLatitude"
    private let lonKey = "lastKnownLongitude"
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Restore last known location from previous session
        let lat = UserDefaults.standard.double(forKey: latKey)
        let lon = UserDefaults.standard.double(forKey: lonKey)
        if lat != 0.0 && lon != 0.0 {
            currentLocation = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
    }
    
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    func startUpdating() {
        manager.startUpdatingLocation()
    }
    
    func stopUpdating() {
        manager.stopUpdatingLocation()
    }
    
    //Request a location fix.
    func requestOnce() {
        manager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last,
              location.horizontalAccuracy >= 0,
              location.horizontalAccuracy < 500 else { return }
        
        DispatchQueue.main.async {
            self.currentLocation = location.coordinate
            // Persist so it's available immediately on next launch
            UserDefaults.standard.set(location.coordinate.latitude, forKey: self.latKey)
            UserDefaults.standard.set(location.coordinate.longitude, forKey: self.lonKey)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Silently handle currentLocation stays as last known
        print("LocationService error: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        default:
            break
        }
    }
}
