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

struct StatCard: View {
    let label: String
    let value: String
    let tint: Color
 
    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.textSecondary)
                .tracking(1.5)
                .textCase(.uppercase)
 
            Text(value)
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundColor(tint)
                .monospacedDigit()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(tint.opacity(0.25), lineWidth: 1)
                )
        )
    }
}

struct TimerRing: View {
    let timeRemaining: Int
    let totalTime: Int
    let isFrozen: Bool
 
    var fraction: Double {
        Double(timeRemaining) / Double(totalTime)
    }
 
    var ringColor: Color {
        if isFrozen       { return .accentCyan }
        if fraction > 0.5 { return .accentCyan }
        if fraction > 0.25 { return .accentViolet }
        return .accentDanger
    }
 
    var body: some View {
        ZStack {
            // Track (always full, dim)
            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: 5)
 
            // Remaining time arc
            Circle()
                .trim(from: 0, to: fraction)
                .stroke(
                    ringColor,
                    style: StrokeStyle(lineWidth: 5, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.5), value: timeRemaining)
 
            // Center text
            VStack(spacing: 0) {
                Text(isFrozen ? "❄️" : "\(timeRemaining)")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(ringColor)
                Text("sec")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.textSecondary)
                    .tracking(1)
            }
        }
        .frame(width: 70, height: 70)
    }
}
 
struct ScoreFlash: View {
    let text: String
    let color: Color
    @State private var opacity: Double = 1.0
    @State private var offset: CGFloat = 0
 
    var body: some View {
        Text(text)
            .font(.system(size: 22, weight: .black, design: .rounded))
            .foregroundColor(color)
            .shadow(color: color.opacity(0.6), radius: 8)
            .offset(y: offset)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 0.9)) {
                    offset = -60
                    opacity = 0
                }
            }
    }
}

struct ActiveBoostBanner: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
 
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(color)
 
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 13, weight: .black))
                    .foregroundColor(color)
                Text(subtitle)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.textSecondary)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(color.opacity(0.4), lineWidth: 1)
                )
        )
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
 
struct FlashInfo: Identifiable {
    let id = UUID()
    let text: String
    let color: Color
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
