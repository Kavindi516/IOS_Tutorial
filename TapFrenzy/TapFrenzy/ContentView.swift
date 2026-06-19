import SwiftUI
internal import Combine

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double( int        & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
 
// Named palette — change these once to retheme the whole app
extension Color {
    static let appBackground  = Color(hex: "08080F") // Deep space black
    static let arenaBackground = Color(hex: "0F0F1C") // Slightly lighter for game zone
    static let accentViolet   = Color(hex: "7B2FFF") // Electric purple
    static let accentCyan     = Color(hex: "00F5FF") // Neon cyan
    static let accentGold     = Color(hex: "FFD700") // Score gold
    static let accentDanger   = Color(hex: "FF3B5C") // Red/danger
    static let accentGreen    = Color(hex: "00E676") // Bonus green
    static let accentGray     = Color(hex: "546E7A") // Penalty gray
    static let textPrimary    = Color.white
    static let textSecondary  = Color(hex: "8899AA")
}

struct EnergyRing: View {
    let combo: Int
    let isBurst: Bool
    @State private var pulse = false
 
    var ringColor: Color {
        if isBurst     { return .accentGold }
        if combo >= 5  { return .accentCyan }
        if combo >= 3  { return .accentViolet }
        return .accentViolet.opacity(0.4)
    }
 
    var ringScale: CGFloat {
        // Ring expands slightly with each combo level
        1.0 + CGFloat(min(combo, 8)) * 0.04
    }
 
    var lineThickness: CGFloat {
        CGFloat(min(combo, 8)) * 0.8 + 1.5
    }
 
    var body: some View {
        ZStack {
            // Outer pulsing ring
            Circle()
                .strokeBorder(ringColor.opacity(pulse ? 0.15 : 0.45), lineWidth: lineThickness + 4)
                .scaleEffect(pulse ? ringScale * 1.18 : ringScale)
                .animation(
                    .easeInOut(duration: 0.9).repeatForever(autoreverses: true),
                    value: pulse
                )
 
            // Inner solid ring — always visible
            Circle()
                .strokeBorder(ringColor, lineWidth: lineThickness)
                .scaleEffect(ringScale)
        }
        .onAppear { pulse = true }
    }
}

struct ContentView: View {
    // Base State Architecture
    @State var score = 0
    @State var timeRemaining = 10
    @State var highScore = 0
    
    // Challenge 1: Combo Tracking
    @State var comboMultiplier = 1
    @State var lastTapTime = Date()
    
    // Challenge 2: Dynamic Colors
    @State var buttonColor: Color = .blue
    
    // Challenge 3: Spatial Offsets (Movement Container Boundings)
    @State var buttonOffset = CGSize.zero
    
    // Challenge 5: Flash Burst Mode Flag
    @State var isBurstActive = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            if timeRemaining > 0 {
                // CORE GAME VIEW
                VStack(spacing: 20) {
                    // Header Metrics Layout
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
                    
                    // Burst Status Ribbon Display
                    if isBurstActive {
                        Text("🔥 BURST ACTIVE: DOUBLE POINTS! 🔥")
                            .font(.headline)
                            .foregroundColor(.yellow)
                            .bold()
                            .transition(.scale)
                    } else {
                        Text("Game Area")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // BOUNDED BOUNDARY ARENA FOR TARGET MOVEMENTS
                    GeometryReader { geometry in
                        ZStack {
                            Button(action: {
                                handleTap()
                            }) {
                                Text("TAP!")
                                    .font(.title).bold()
                                    .foregroundColor(.white)
                                    .padding(.vertical, 35)
                                    .padding(.horizontal, 50)
                                    // Burst overrides normal color configurations
                                    .background(isBurstActive ? Color.yellow : buttonColor)
                                    .cornerRadius(20)
                                    .shadow(radius: 5)
                            }
                            // Challenge 3 & 4 Offset/Scaling modifiers
                            .offset(buttonOffset)
                            .scaleEffect(CGFloat(timeRemaining) / 10.0 * 0.7 + 0.3)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onAppear {
                            // Center alignment initialization
                            buttonOffset = CGSize.zero
                        }
                    }
                    .frame(height: 350)
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .onReceive(timer) { _ in
                    processGameTick()
                }
                
            } else {
                // THE GAME OVER VIEW
                VStack(spacing: 20) {
                    Text("Game Over!")
                        .font(.largeTitle).bold()
                        .foregroundColor(.red)
                    
                    Text("Final Score: \(score)")
                        .font(.title)
                    
                    Text("High Score: \(highScore)")
                        .font(.title3).foregroundColor(.gray)
                    
                    Button(action: {
                        resetGame()
                    }) {
                        Text("Play Again")
                            .font(.headline).foregroundColor(.white)
                            .padding().background(Color.green).cornerRadius(10)
                    }
                    .padding(.top, 20)
                }
            }
        }
    }
    
    // --- APP REFACTOR MECHANICS ENGINE ---
    
    // Master Input Action Evaluator
    func handleTap() {
        let now = Date()
        if now.timeIntervalSince(lastTapTime) <= 0.5 {
            comboMultiplier += 1
        } else {
            comboMultiplier = 1
        }
        lastTapTime = now
        
        // Value computation bases
        var basePoint = 1
        if buttonColor == .gray {
            basePoint = -2  // Penalty state rule
        } else if buttonColor == .green {
            basePoint = 2   // Bonus state rule
        }
        
        if isBurstActive {
            basePoint *= 2  // Multiplier compounding for bursts
        }
        
        score += (basePoint * comboMultiplier)
    }
    
    // 1-Second Cycle Process Loop Evaluator
    func processGameTick() {
        if timeRemaining > 0 {
            timeRemaining -= 1
            
            // Challenge 2: Every single second, shuffle button modifier distributions
            let roller = Int.random(in: 1...3)
            if roller == 1 {
                buttonColor = .green
            } else if roller == 2 {
                buttonColor = .gray
            } else {
                buttonColor = .blue
            }
            
            // Challenge 3: Relocate position coordinates every alternate second block
            if timeRemaining % 2 == 0 {
                withAnimation(.easeInOut(duration: 0.4)) {
                    buttonOffset = CGSize(
                        width: CGFloat.random(in: -80...80),
                        height: CGFloat.random(in: -110...110)
                    )
                }
            }
            
            // Challenge 5: Enable burst window state when remaining time falls to exactly 5 seconds
            if timeRemaining == 5 {
                isBurstActive = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.isBurstActive = false
                }
            }
        }
        
        // Wrap up execution logic
        if timeRemaining == 0 {
            comboMultiplier = 1
            buttonOffset = CGSize.zero
            if score > highScore { highScore = score }
        }
    }
    
    // Master Match Reset Execution
    func resetGame() {
        score = 0
        timeRemaining = 10
        comboMultiplier = 1
        buttonColor = .blue
        buttonOffset = CGSize.zero
        isBurstActive = false
    }
}
