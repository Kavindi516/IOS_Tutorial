import SwiftUI
internal import Combine

struct ContentView: View {
    @State var score = 0
    @State var timeRemaining = 10
    @State var highScore = 0
    
    // Core 1-second interval timer declaration
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            if timeRemaining > 0 {
                // ACTIVE GAMEPLAY SCREEN
                VStack(spacing: 30) {
                    HStack {
                        Text("Time: \(timeRemaining)s")
                            .font(.title2).bold()
                        Spacer()
                        Text("Score: \(score)")
                            .font(.title2).bold()
                    }
                    .padding()
                    
                    Spacer()
                    
                    ZStack {
                        Button(action: {
                            score += 1 // Basic tap increment logic
                        }) {
                            Text("TAP!")
                                .font(.title).bold()
                                .foregroundColor(.white)
                                .padding(.vertical, 40)
                                .padding(.horizontal, 60)
                                .background(Color.blue)
                                .cornerRadius(20)
                        }
                    }
                    .frame(height: 300)
                    
                    Spacer()
                }
                .padding()
                // Listen for every second tick of the timer
                .onReceive(timer) { _ in
                    if timeRemaining > 0 {
                        timeRemaining -= 1
                    }
                    // Capture high score instantly when game concludes
                    if timeRemaining == 0 && score > highScore {
                        highScore = score
                    }
                }
                
            } else {
                // GAME OVER SCREEN
                VStack(spacing: 20) {
                    Text("Game Over!")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.red)
                    
                    Text("Final Score: \(score)")
                        .font(.title)
                    
                    Text("High Score: \(highScore)")
                        .font(.title3)
                        .foregroundColor(.gray)
                    
                    Button(action: {
                        // Reset properties to fresh state values
                        score = 0
                        timeRemaining = 10
                    }) {
                        Text("Play Again")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    .padding(.top, 20)
                }
            }
        }
    }
}
