//
//  MapTab.swift
//  LightItUp
//
//  Created by Student2 on 2026-07-08.
//

import SwiftUI
import MapKit
 
struct MapTab: View {
    @EnvironmentObject var statsVM: StatsViewModel
    @StateObject private var locationService = LocationService.shared
    @State private var selectedSession: GameSession? = nil
    @State private var cameraPosition: MapCameraPosition = .automatic
 
    // Only sessions that have a location
    private var mappableSessions: [GameSession] {
        statsVM.sessions.filter { $0.coordinate != nil }
    }
 
    var body: some View {
        NavigationStack {
            ZStack {
                if mappableSessions.isEmpty {
                    emptyState
                } else {
                    Map(position: $cameraPosition) {
                        ForEach(mappableSessions) { session in
                            Annotation(
                                session.mode.rawValue,
                                coordinate: session.coordinate!
                            ) {
                                pinView(for: session)
                                    .onTapGesture {
                                        withAnimation(.spring()) {
                                            selectedSession = session
                                        }
                                    }
                            }
                        }
                    }
                    .mapStyle(.standard(elevation: .realistic))
                    .ignoresSafeArea(edges: .bottom)
                }
 
                // Session detail popup
                if let session = selectedSession {
                    VStack {
                        Spacer()
                        sessionDetailCard(session)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .navigationTitle("Map of Games")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if selectedSession != nil {
                        Button("Close") {
                            withAnimation { selectedSession = nil }
                        }
                        .foregroundColor(Color(hex: "7B61FF"))
                    }
                }
            }
            .onAppear {
                locationService.requestPermission()
            }
        }
    }
 
    // MARK: – Pin view
    private func pinView(for session: GameSession) -> some View {
        ZStack {
            Circle()
                .fill(session.mode.color)
                .frame(width: 36, height: 36)
                .shadow(color: session.mode.color.opacity(0.6), radius: 6)
            Image(systemName: session.mode.icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
        }
        .scaleEffect(selectedSession?.id == session.id ? 1.3 : 1.0)
        .animation(.spring(response: 0.3), value: selectedSession?.id)
    }
 
    // MARK: – Session detail card
    private func sessionDetailCard(_ session: GameSession) -> some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(session.mode.color.opacity(0.2))
                    .frame(width: 52, height: 52)
                Image(systemName: session.mode.icon)
                    .font(.system(size: 24))
                    .foregroundColor(session.mode.color)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(session.mode.rawValue)
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text(session.formattedDate)
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "8899AA"))
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(session.score)")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(session.mode.color)
                Text("points")
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "8899AA"))
            }
        }
        .padding(18)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(session.mode.color.opacity(0.4), lineWidth: 1)
        )
    }
 
    // MARK: – Empty state
    private var emptyState: some View {
        ZStack {
            Color(white: 0.06).ignoresSafeArea()
            VStack(spacing: 16) {
                Text("🗺️")
                    .font(.system(size: 60))
                Text("No locations yet")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text("Complete a game to drop a pin here.\nMake sure location permission is on.")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "8899AA"))
                    .multilineTextAlignment(.center)
            }
        }
    }
}
