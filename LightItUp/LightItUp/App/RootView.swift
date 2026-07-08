//
//  RootView.swift
//  LightItUp
//
//  Created by Student2 on 2026-07-08.
//

import SwiftUI
 
struct RootView: View {
    @StateObject private var statsVM = StatsViewModel()
 
    var body: some View {
        TabView {
            HomeTab()
                .tabItem {
                    Label("Home", systemImage: "gamecontroller.fill")
                }
 
            StatsTab()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
 
            MapTab()
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }
 
            SettingsTab()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .tint(Color(hex: "7B61FF"))   // purple accent on selected tab
        .environmentObject(statsVM)
        .preferredColorScheme(.dark)
    }
}
 
