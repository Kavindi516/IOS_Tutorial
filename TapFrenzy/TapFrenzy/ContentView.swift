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
    
    // Challenge 2: Trap Colour
    @State var buttonColor: Color = .accentViolet
    
    // Challenge 3: Spatial Offsets (Movement Container Boundings)
    @State var buttonOffset = CGSize.zero
    
    
    // Challenge 5: Flash Burst Mode Flag
    @State var isBurstActive = false
    
    //Challenge 6: Ghost Mode
    @State var isGhostActive = false
    @State var ghostCooldown = 3

    //Challenge 7: Lucky Star
    @State var isLuckyActive = false

    //Challenge 8: Time Freeze
    @State var freezeAvailable = false
    @State var freezeUsed = false
    @State var isTimeFrozen = false
    
    //Score Flash UI
    @State var flashes: [FlashInfo] = []
    
    //Timer
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
    

    func processGameTick() {
            guard timeRemaining > 0 else { return }
     
            // ── Time Freeze (Challenge 8) ─────────────
            // If frozen, skip decrement this tick
            if !isTimeFrozen {
                timeRemaining -= 1
            }
     
            // ── Challenge 2: Trap Colour ──────────────
            // Every second, randomly assign green/gray/violet.
            // Probabilities: 25% green bonus, 25% gray penalty, 50% normal
            let roll = Int.random(in: 1...4)
            switch roll {
            case 1:    buttonColor = .accentGreen
            case 2:    buttonColor = .accentGray
            default:   buttonColor = .accentViolet
            }
     
            // ── Challenge 3: Moving Target ────────────
            // Every even second, jump to new random position.
            // The arena is ~350pt tall and ~340pt wide;
            // offsets are constrained so the button stays
            // mostly inside the frame.
            if timeRemaining % 2 == 0 {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.65)) {
                    buttonOffset = CGSize(
                        width:  CGFloat.random(in: -90...90),
                        height: CGFloat.random(in: -100...100)
                    )
                }
            }
     
            // ── Challenge 5: Burst Mode ───────────────
            // Activates ONCE when timer first hits 5 seconds.
            // DispatchAfter deactivates it after 2 seconds.
            if timeRemaining == 5 && !isBurstActive {
                withAnimation { isBurstActive = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation { self.isBurstActive = false }
                }
            }
     
            // ── Challenge 6: Ghost Mode ───────────────
            // ghostCooldown counts down each second.
            // When it reaches 0, trigger ghost for 1.5s,
            // then reset cooldown to 3-4 seconds.
            if ghostCooldown > 0 {
                ghostCooldown -= 1
            }
            if ghostCooldown == 0 && !isGhostActive && timeRemaining > 2 {
                withAnimation { isGhostActive = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation { self.isGhostActive = false }
                }
                ghostCooldown = Int.random(in: 3...4)
            }
     
            // ── Challenge 7: Lucky Star ───────────────
            // 20% chance each second to show Lucky Star.
            // Lucky stays active for 1.5s if not tapped.
            if !isLuckyActive && Int.random(in: 1...5) == 1 {
                withAnimation { isLuckyActive = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation { self.isLuckyActive = false }
                }
            }
     
            // ── Challenge 8: Freeze Button Visibility ─
            // Available between seconds 4–8.
            // Once used (freezeUsed = true) it stays hidden.
            withAnimation(.spring()) {
                freezeAvailable = (timeRemaining >= 4 && timeRemaining <= 7 && !freezeUsed)
            }
     
            // ── Game Over ─────────────────────────────
            if timeRemaining == 0 {
                comboMultiplier = 1
                buttonOffset     = .zero
                isBurstActive    = false
                isGhostActive    = false
                isLuckyActive    = false
                if score > highScore { highScore = score }
            }
        }
    
    
    func activateTimeFreeze() {
            guard !freezeUsed else { return }
            freezeUsed = true
            withAnimation { isTimeFrozen = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation { self.isTimeFrozen = false }
            }
        }
    // Master Match Reset Execution
    func resetGame() {
            score           = 0
            timeRemaining   = 10
            comboMultiplier = 1
            lastTapTime     = Date()
            buttonColor     = .accentViolet
            buttonOffset    = .zero
            isBurstActive   = false
            isGhostActive   = false
            isLuckyActive   = false
            freezeAvailable = false
            freezeUsed      = false
            isTimeFrozen    = false
            ghostCooldown   = 3
            flashes         = []
        }
    }
     
#Preview {
    ContentView()
}

    
