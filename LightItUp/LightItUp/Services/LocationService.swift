//
//  LocationService.swift
//  LightItUp
//
//  Created by Student2 on 2026-07-08.
//

import CoreLocation
internal import Combine
 
@MainActor
class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
 
    static let shared = LocationService()
 
    @Published var lastLocation: CLLocation? = nil
    @Published var authStatus: CLAuthorizationStatus = .notDetermined
 
    private let manager = CLLocationManager()
 
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        authStatus = manager.authorizationStatus
    }
 
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }
 
    func startUpdating() {
        manager.startUpdatingLocation()
    }
 
    // MARK: – Delegate
    nonisolated func locationManager(_ manager: CLLocationManager,
                                     didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        Task { @MainActor in self.lastLocation = loc }
    }
 
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authStatus = manager.authorizationStatus
            if manager.authorizationStatus == .authorizedWhenInUse {
                manager.startUpdatingLocation()
            }
        }
    }
}
