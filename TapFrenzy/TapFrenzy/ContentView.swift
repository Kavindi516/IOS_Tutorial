import SwiftUI
internal import Combine

struct ContentView: View {
    @State var score = 0
    @State var timeRemaining = 10
    @State var highScore = 0
    
    // Challenge 1 States
    @State var comboMultiplier = 1
    @State var lastTapTime = Date()
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            if timeRemaining > 0 {
                VStack(spacing: 30) {
                    HStack {
                        Text("Time: \(timeRemaining)s")
                            .font(.title2).bold()
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("Score: \(score)")
                                .font(.title2).bold()
                            Text("Combo: x\(comboMultiplier)")
                                .font(.caption).bold()
                                .foregroundColor(.orange)
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    ZStack {
                        Button(action: {
                            // Combo Calculation Engine
                            let now = Date()
                            if now.timeIntervalSince(lastTapTime) <= 0.5 {
                                comboMultiplier += 1
                            } else {
                                comboMultiplier = 1
                            }
                            lastTapTime = now
                            
                            // Add score factoring in the multiplier
                            score += (1 * comboMultiplier)
                        }) {
                            Text("TAP!")
                                .font(.title).bold()
                                .foregroundColor(.white)
                                .padding(.vertical, 40)
                                .padding(.horizontal, 60)
                                .background(Color.blue)
                                .cornerRadius(20)
                        }
                        // Challenge 4: Shrinking Button Modifier
                        // Baseline scaling formula ensures button remains functional at 30% sizing near 0s
                        .scaleEffect(CGFloat(timeRemaining) / 10.0 * 0.7 + 0.3)
                    }
                    .frame(height: 300)
                    
                    Spacer()
                }
                .padding()
                .onReceive(timer) { _ in
                    if timeRemaining > 0 {
                        timeRemaining -= 1
                    }
                    if timeRemaining == 0 {
                        comboMultiplier = 1 // Reset combo for next match
                        if score > highScore { highScore = score }
                    }
                }
            } else {
                // Game Over Screen (Kept identical to Commit 3)
                VStack(spacing: 20) {
                    Text("Game Over!").font(.largeTitle).bold().foregroundColor(.red)
                    Text("Final Score: \(score)").font(.title)
                    Text("High Score: \(highScore)").font(.title3).foregroundColor(.gray)
                    Button("Play Again") {
                        score = 0
                        timeRemaining = 10
                    }
                    .font(.headline).foregroundColor(.white).padding().background(Color.green).cornerRadius(10)
                }
            }
        }
    }
}
