//
//  ContentView.swift
//  TapFrenzy
//
//  Created by Student2 on 2026-06-10.
//

import SwiftUI

struct ContentView: View {
    // Basic placeholder states for visual verification
    @State var score = 0
    @State var timeRemaining = 10
    
    var body: some View {
        VStack(spacing: 30) {
            // Header Stats Area
            HStack {
                Text("Time: \(timeRemaining)s")
                    .font(.title2)
                    .bold()
                Spacer()
                Text("Score: \(score)")
                    .font(.title2)
                    .bold()
            }
            .padding()
            
            Spacer()
            
            // Interactive Gameplay Arena
            ZStack {
                Button(action: {
                    // Action will go here in Commit 3
                }) {
                    Text("TAP!")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.vertical, 40)
                        .padding(.horizontal, 60)
                        .background(Color.blue)
                        .cornerRadius(20)
                }
            }
            .frame(height: 300) // Keeps the game area distinct
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
