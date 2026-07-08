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


struct TapFrenzyView: View {
    // Base State Architecture
    @State var score = 0
    @State var timeRemaining = 10
    @AppStorage("highScore_tapFrenzy") var highScore: Int = 0
    
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
            ZStack {
                // Full-screen background
                Color.appBackground.ignoresSafeArea()
     
                if timeRemaining > 0 {
                    gameView
                } else {
                    gameOverView
                }
            }
            .onReceive(timer) { _ in
                processGameTick()
            }
        }
    
    
    var gameView: some View {
            VStack(spacing: 12) {
     
                // ── TOP HUD: Score / Timer / Combo ──────
                // Three StatCards + TimerRing in a row.
                // HStack with a Spacer in the middle keeps
                // the left cards and the ring visually balanced.
                HStack(spacing: 10) {
                    StatCard(label: "Score",   value: "\(score)",             tint: .accentGold)
                    StatCard(label: "Combo",   value: "×\(comboMultiplier)",  tint: .accentViolet)
                    Spacer()
                    TimerRing(timeRemaining: timeRemaining, totalTime: 10, isFrozen: isTimeFrozen)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
     
                // ── HIGH SCORE STRIP ─────────────────
                HStack {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.accentGold.opacity(0.7))
                    Text("Best: \(highScore)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.textSecondary)
                }
                .padding(.horizontal, 20)
     
                // ── ACTIVE CHALLENGE BANNERS ──────────
                // Show one banner at a time (in priority order).
                // withAnimation wraps the if/else so banners
                // slide in/out smoothly using the transition
                // defined inside ActiveBoostBanner.
                VStack(spacing: 6) {
                    if isBurstActive {
                        ActiveBoostBanner(
                            icon:     "bolt.fill",
                            title:    "BURST ACTIVE",
                            subtitle: "Double points for 2 seconds!",
                            color:    .accentGold
                        )
                    }
                    if isGhostActive {
                        ActiveBoostBanner(
                            icon:     "eye.slash.fill",
                            title:    "GHOST MODE",
                            subtitle: "Tap from memory — button is invisible!",
                            color:    .accentCyan
                        )
                    }
                    if isLuckyActive {
                        ActiveBoostBanner(
                            icon:     "star.fill",
                            title:    "LUCKY STAR ×5",
                            subtitle: "Next tap scores 5× — don't miss!",
                            color:    .accentGold
                        )
                    }
                    if isTimeFrozen {
                        ActiveBoostBanner(
                            icon:     "snowflake",
                            title:    "TIME FROZEN",
                            subtitle: "Timer paused for 3 seconds!",
                            color:    .accentCyan
                        )
                    }
                }
                .padding(.horizontal, 16)
                .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isBurstActive)
                .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isGhostActive)
                .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isLuckyActive)
                .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isTimeFrozen)
     
                // ── GAME ARENA ────────────────────────
                // GeometryReader gives us the arena frame
                // so we can constrain the button offset.
                // ZStack layers: background → EnergyRing → button → flash texts.
                GeometryReader { geometry in
                    ZStack {
                        // Arena background with subtle border
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.arenaBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .strokeBorder(Color.accentViolet.opacity(0.15), lineWidth: 1)
                            )
     
                        // Floating score flashes
                        // Each FlashInfo in the array gets its own
                        // ScoreFlash view. They are removed after the
                        // animation completes (0.9s).
                        ForEach(flashes) { flash in
                            ScoreFlash(text: flash.text, color: flash.color)
                                .offset(buttonOffset)
                                .offset(y: -70)
                        }
     
                        // EnergyRing + Button group, moved together by offset
                        ZStack {
                            // Energy ring is sized relative to the button
                            EnergyRing(combo: comboMultiplier, isBurst: isBurstActive)
                                .frame(width: 130, height: 130)
     
                            Button(action: { handleTap() }) {
                                ZStack {
                                    // Button background
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(tapButtonColor)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .strokeBorder(tapButtonBorderColor, lineWidth: 1.5)
                                        )
     
                                    // Button label changes based on active challenge
                                    VStack(spacing: 2) {
                                        if isGhostActive {
                                            // Empty during ghost — the button is invisible
                                            Text(" ")
                                                .font(.system(size: 28, weight: .black, design: .rounded))
                                        } else if isLuckyActive {
                                            Text("★")
                                                .font(.system(size: 28, weight: .black, design: .rounded))
                                                .foregroundColor(.accentGold)
                                            Text("TAP!")
                                                .font(.system(size: 14, weight: .black, design: .rounded))
                                                .foregroundColor(.white.opacity(0.8))
                                        } else {
                                            Text("TAP!")
                                                .font(.system(size: 30, weight: .black, design: .rounded))
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                                .frame(width: 110, height: 110)
                            }
                            .buttonStyle(PlainButtonStyle())
                            // Ghost: opacity 0 makes it invisible but still tappable
                            .opacity(isGhostActive ? 0.0 : 1.0)
                            // Challenge 4 (Shrinking): scale interpolated from 1.0 → 0.4
                            .scaleEffect(buttonShrinkScale)
                        }
                        .offset(buttonOffset)
                    }
                }
                .frame(maxHeight: .infinity)
                .padding(.horizontal, 16)
     
                // ── TIME FREEZE BUTTON ────────────────
                // Only visible between seconds 7 and 4.
                // Uses .disabled(freezeUsed) so it grays out
                // after first use. The label changes to show
                // it's been consumed.
                if freezeAvailable && !freezeUsed {
                    Button(action: { activateTimeFreeze() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "snowflake")
                                .font(.system(size: 14, weight: .bold))
                            Text("FREEZE TIME")
                                .font(.system(size: 13, weight: .black))
                                .tracking(0.5)
                        }
                        .foregroundColor(.accentCyan)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Color.accentCyan.opacity(0.12))
                                .overlay(
                                    Capsule()
                                        .strokeBorder(Color.accentCyan.opacity(0.5), lineWidth: 1.5)
                                )
                        )
                    }
                    .transition(.scale.combined(with: .opacity))
                    .animation(.spring(), value: freezeAvailable)
                }
     
                Spacer(minLength: 8)
            }
        }
    
    var gameOverView: some View {
            VStack(spacing: 0) {
                Spacer()
     
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.accentDanger.opacity(0.12))
                        .frame(width: 90, height: 90)
                    Image(systemName: "flag.checkered")
                        .font(.system(size: 38))
                        .foregroundColor(.accentDanger)
                }
                .padding(.bottom, 24)
     
                Text("GAME OVER")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundColor(.textPrimary)
                    .tracking(2)
     
                // New high score callout (only shown if beaten)
                if score == highScore && score > 0 {
                    HStack(spacing: 6) {
                        Image(systemName: "trophy.fill")
                            .foregroundColor(.accentGold)
                        Text("NEW HIGH SCORE!")
                            .font(.system(size: 13, weight: .black))
                            .foregroundColor(.accentGold)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule().fill(Color.accentGold.opacity(0.12))
                            .overlay(Capsule().strokeBorder(Color.accentGold.opacity(0.4), lineWidth: 1))
                    )
                    .padding(.top, 12)
                }
     
                // Final score — gold if new high, else white
                Text("\(score)")
                    .font(.system(size: 80, weight: .black, design: .rounded))
                    .foregroundColor(score == highScore && score > 0 ? .accentGold : .textPrimary)
                    .monospacedDigit()
                    .padding(.top, 8)
     
                Text("POINTS")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.textSecondary)
                    .tracking(3)
     
                // Previous best (shown when score doesn't beat it)
                if score < highScore {
                    HStack(spacing: 6) {
                        Image(systemName: "trophy")
                            .font(.system(size: 12))
                            .foregroundColor(.textSecondary)
                        Text("Best: \(highScore)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.textSecondary)
                    }
                    .padding(.top, 8)
                }
     
                Spacer()
     
                // Play Again button
                Button(action: { resetGame() }) {
                    HStack(spacing: 10) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 16, weight: .bold))
                        Text("PLAY AGAIN")
                            .font(.system(size: 17, weight: .black))
                            .tracking(1)
                    }
                    .foregroundColor(.appBackground)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [.accentCyan, .accentViolet],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
                
                ShareLink(
                    item: "I just scored \(score) on Tap Frenzy — beat that! ⚡",
                    subject: Text("Tap Frenzy Score"),
                    message: Text("Can you beat \(score) points?")
                ) {
                    HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share Score")
                    .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(.accentCyan)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.white.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
    
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
            }
        }
     
    
    // Button background color based on current active challenge state
        var tapButtonColor: Color {
            if isBurstActive  { return Color.accentGold.opacity(0.25) }
            if isLuckyActive  { return Color(hex: "332B00")           }
            if buttonColor == .accentGreen  { return Color(hex: "003320") }
            if buttonColor == .accentGray   { return Color(hex: "1A2030") }
            return Color.accentViolet.opacity(0.18)
        }
     
        // Button border stroke changes with active state
        var tapButtonBorderColor: Color {
            if isBurstActive  { return .accentGold }
            if isLuckyActive  { return .accentGold }
            return buttonColor.opacity(0.7)
        }
     
        // Challenge 4: Button shrinks from full (1.0) to 40% (0.4)
        // Formula: maps 10→0 seconds onto 1.0→0.4 scale
        var buttonShrinkScale: CGFloat {
            let t = CGFloat(timeRemaining) / 10.0
            return t * 0.6 + 0.4   // range: [0.4, 1.0]
        }
    

    
    // --- APP REFACTOR MECHANICS ENGINE ---
    
    // Master Input Action Evaluator
    func handleTap() {
            let now = Date()
     
            // ── Combo logic (Challenge 1) ──────────
            // If we tapped within 0.5s of the last tap,
            // increment combo. Otherwise reset to 1.
            if now.timeIntervalSince(lastTapTime) <= 0.5 {
                comboMultiplier += 1
            } else {
                comboMultiplier = 1
            }
            lastTapTime = now
     
            // ── Base points (Challenge 2: Trap Colour) ──
            var basePoints = 1
            if buttonColor == .accentGray  { basePoints = -2 }  // penalty
            if buttonColor == .accentGreen { basePoints =  2 }  // bonus
     
            // ── Lucky Star multiplier (Challenge 7) ──
            // If lucky is active this tap, multiply base by 5
            // then deactivate so it only fires once.
            if isLuckyActive {
                basePoints *= 5
                isLuckyActive = false
            }
     
            // ── Burst multiplier (Challenge 5) ──────
            if isBurstActive { basePoints *= 2 }
     
            // ── Apply combo ───────────────────────────
            let totalPoints = basePoints * comboMultiplier
     
            // ── Score flash text ──────────────────────
            let flashText = buildFlashText(points: totalPoints, base: basePoints)
            let flashColor: Color = totalPoints >= 0 ? .accentGold : .accentDanger
            addFlash(text: flashText, color: flashColor)
     
            score += totalPoints
        }
     
        // Builds the human-readable flash string: e.g. "+2 ×3" or "-2" or "★+10"
        func buildFlashText(points: Int, base: Int) -> String {
            let sign   = points >= 0 ? "+" : ""
            let prefix = isLuckyActive ? "★" : ""
            if comboMultiplier > 1 {
                return "\(prefix)\(sign)\(base) ×\(comboMultiplier)"
            }
            return "\(prefix)\(sign)\(points)"
        }
     
        // Adds a new flash, then removes it after the animation (0.95s)
        func addFlash(text: String, color: Color) {
            let f = FlashInfo(text: text, color: color)
            flashes.append(f)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.95) {
                flashes.removeAll { $0.id == f.id }
            }
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
                SessionSaver.save(mode: .tapFrenzy, score: score)
                
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
    TapFrenzyView()
}

    
