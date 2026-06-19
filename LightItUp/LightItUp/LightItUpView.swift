import SwiftUI
 
struct LightItUpView: View {
    @StateObject private var vm = LightItUpViewModel()
    @AppStorage("highScore_lightItUp") private var storedHigh: Int = 0
 
    // Settings sheet (bonus feature)
    @State private var showSettings = false
    @State private var roundLength: Double = 60
 
    var body: some View {
        ZStack {
            // Background
            Color(white: 0.06).ignoresSafeArea()
 
            VStack(spacing: 0) {
                hud
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
 
                Spacer(minLength: 12)
 
                if vm.isRunning || vm.isGameOver {
                    grid
                        .padding(.horizontal, 16)
                } else {
                    startScreen
                }
 
                Spacer(minLength: 16)
            }
 
            // Level-up flash overlay
            if vm.showLevelFlash {
                levelFlash
            }
 
            // Game-over sheet
            if vm.isGameOver {
                gameOverOverlay
            }
        }
        .navigationTitle("Light It Up")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showSettings = true } label: {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            settingsSheet
        }
    }
 
    // MARK: – HUD
    private var hud: some View {
        HStack(spacing: 12) {
            // Level badge
            Text(vm.currentLevel.label)
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundColor(.black)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(vm.currentLevel.color)
                .clipShape(Capsule())
                .animation(.easeInOut(duration: 0.3), value: vm.currentLevel)
 
            Spacer()
 
            // Lives (hearts)
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { i in
                    Image(systemName: i < vm.lives ? "heart.fill" : "heart")
                        .foregroundColor(i < vm.lives ? .red : .gray.opacity(0.4))
                        .font(.system(size: 15))
                }
            }
 
            Spacer()
 
            // Score
            VStack(alignment: .trailing, spacing: 0) {
                Text("\(vm.score)")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text("SCORE")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.gray)
            }
        }
        .padding(14)
        .background(Color(white: 0.11))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
 
    // MARK: – Timer ring (shown above grid when running)
    @ViewBuilder private var grid: some View {
        VStack(spacing: 14) {
            timerBar
 
            let columns = Array(
                repeating: GridItem(.flexible(), spacing: 12),
                count: vm.currentLevel.columns
            )
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(vm.cards) { card in
                    CardView(card: card, levelColor: vm.currentLevel.color) {
                        vm.tap(card: card)
                    }
                    .aspectRatio(1, contentMode: .fit)
                }
            }
            .animation(.easeInOut(duration: 0.25), value: vm.currentLevel.cardCount)
        }
    }
 
    private var timerBar: some View {
        let fraction = vm.timeRemaining / 60
        return GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 6)
                RoundedRectangle(cornerRadius: 4)
                    .fill(timerBarColor(fraction: fraction))
                    .frame(width: geo.size.width * CGFloat(max(0, fraction)), height: 6)
                    .animation(.linear(duration: 0.1), value: vm.timeRemaining)
            }
        }
        .frame(height: 6)
        .overlay(
            HStack {
                Spacer()
                Text(String(format: "%.0f s", vm.timeRemaining))
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.5))
                    .offset(y: -14)
            }
        )
    }
 
    private func timerBarColor(fraction: Double) -> Color {
        fraction > 0.5 ? vm.currentLevel.color : (fraction > 0.25 ? .orange : .red)
    }
 
    // MARK: – Start screen
    private var startScreen: some View {
        VStack(spacing: 32) {
            VStack(spacing: 8) {
                Text("💡")
                    .font(.system(size: 64))
                Text("Light It Up")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text("Tap the lit card before it goes dark.\nMiss or tap wrong — you lose a life.")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
 
            // Level legend
            VStack(spacing: 10) {
                ForEach(Level.allCases, id: \.self) { lvl in
                    HStack(spacing: 12) {
                        Text(lvl.label)
                            .font(.system(size: 12, weight: .black, design: .rounded))
                            .foregroundColor(.black)
                            .frame(width: 32, height: 24)
                            .background(lvl.color)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        Text("\(lvl.cardCount) cards · \(String(format: "%.2g", lvl.litWindow))s window\(lvl.litCount > 1 ? " · \(lvl.litCount) lit" : "")")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.7))
                        Spacer()
                    }
                }
            }
            .padding(16)
            .background(Color(white: 0.11))
            .clipShape(RoundedRectangle(cornerRadius: 14))
 
            // High score
            if storedHigh > 0 {
                HStack {
                    Image(systemName: "trophy.fill").foregroundColor(.yellow)
                    Text("Best: \(storedHigh)")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.yellow)
                }
            }
 
            Button {
                vm.start(roundLength: roundLength)
            } label: {
                Text("TAP TO PLAY")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color(hex: "4FC3F7"))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(.horizontal, 24)
    }
 
    // MARK: – Level-up flash overlay
    private var levelFlash: some View {
        ZStack {
            vm.currentLevel.color.opacity(0.18).ignoresSafeArea()
            VStack(spacing: 8) {
                Text("LEVEL \(vm.currentLevel.rawValue)")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(vm.currentLevel.color)
                Text("↑ Speed up!")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.25), value: vm.showLevelFlash)
    }
 
    // MARK: – Game-over overlay
    private var gameOverOverlay: some View {
        ZStack {
            Color.black.opacity(0.75).ignoresSafeArea()
            VStack(spacing: 24) {
                Text(vm.newHighScore ? "🏆 NEW BEST!" : "⏱ Time's Up")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(vm.newHighScore ? .yellow : .white)
 
                VStack(spacing: 6) {
                    Text("\(vm.score)")
                        .font(.system(size: 56, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Text("SCORE")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.gray)
                }
 
                if !vm.newHighScore {
                    HStack {
                        Image(systemName: "trophy.fill").foregroundColor(.yellow)
                        Text("Best: \(storedHigh)")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.yellow)
                    }
                }
 
                VStack(spacing: 12) {
                    Button {
                        vm.start(roundLength: roundLength)
                    } label: {
                        Text("PLAY AGAIN")
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(hex: "4FC3F7"))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    Button {
                        vm.reset()
                    } label: {
                        Text("HOME")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.6))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(white: 0.14))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
            }
            .padding(32)
            .background(Color(white: 0.10))
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .padding(.horizontal, 28)
        }
    }
 
    // MARK: – Settings sheet
    private var settingsSheet: some View {
        NavigationStack {
            Form {
                Section("Round Length") {
                    Picker("Duration", selection: $roundLength) {
                        Text("30 seconds").tag(30.0)
                        Text("60 seconds").tag(60.0)
                        Text("90 seconds").tag(90.0)
                    }
                    .pickerStyle(.segmented)
                }
                Section("High Score") {
                    HStack {
                        Text("Light It Up Best")
                        Spacer()
                        Text("\(storedHigh)")
                            .foregroundColor(.secondary)
                    }
                    Button("Reset High Score", role: .destructive) {
                        UserDefaults.standard.removeObject(forKey: "highScore_lightItUp")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { showSettings = false }
                }
            }
        }
    }
}
 
#Preview {
    NavigationStack {
        LightItUpView()
    }
}
