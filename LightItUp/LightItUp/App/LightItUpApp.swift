//
//  LightItUpApp.swift
//  LightItUp
//
//  Created by Student2 on 2026-06-19.
//

import SwiftUI
 
@main
struct LightItUpApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
 
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
 
// AppDelegate: request location on launch
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        LocationService.shared.requestPermission()
        return true
    }
}
