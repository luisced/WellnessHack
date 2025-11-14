import SwiftUI
import SplineRuntime

// MARK: - Break Screen

struct BreakScreen: View {
    let onBackToMain: () -> Void
    @State private var breakTimer: Int = 300 // 5 minutes default
    @State private var isTimerActive = false
    @State private var timer: Timer?
    
    init(onBackToMain: @escaping () -> Void = {}) {
        self.onBackToMain = onBackToMain
    }
    
    var body: some View {
        ZStack {
            // Background with gradient
            LinearGradient(
                colors: [
                    Color.purple.opacity(0.8),
                    Color.blue.opacity(0.6),
                    Color.cyan.opacity(0.4)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(.all)
            
            // Spline background if available
            if let url = Bundle.main.url(
                forResource: "meditation_copy",
                withExtension: "splineswift"
            ) {
                SplineView(sceneFileURL: url)
                    .ignoresSafeArea(.all)
                    .opacity(0.3)
            }
            
            VStack(spacing: 30) {
                // Header
                breakHeader
                
                Spacer()
                
                // Timer Circle
                timerCircle
                
                Spacer()
                
                // Break Tips
                breakTips
                
                // Control Buttons
                controlButtons
                
                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    // MARK: - Break Header
    
    private var breakHeader: some View {
        VStack(spacing: 10) {
            Text("Hora del Break")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Tómate un momento para recargar energías")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 50)
    }
    
    // MARK: - Timer Circle
    
    private var timerCircle: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 12)
                .frame(width: 200, height: 200)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: [.white, .cyan],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: progress)
            
            // Timer text
            VStack(spacing: 8) {
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                
                Text(formatTime(breakTimer))
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(isTimerActive ? "En curso..." : "Listo para empezar")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
    
    // MARK: - Break Tips
    
    private var breakTips: some View {
        VStack(spacing: 15) {
            Text("Sugerencias para tu break:")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 10) {
                TipRow(icon: "drop.fill", text: "Bebe un vaso de agua")
                TipRow(icon: "lungs.fill", text: "Haz 5 respiraciones profundas")
                TipRow(icon: "eye.fill", text: "Descansa la vista por 30 segundos")
                TipRow(icon: "figure.walk", text: "Estira las piernas")
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.1))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - Control Buttons
    
    private var controlButtons: some View {
        HStack(spacing: 30) {
            // Start/Pause Button
            Button(action: toggleTimer) {
                HStack {
                    Image(systemName: isTimerActive ? "pause.fill" : "play.fill")
                        .font(.title2)
                    Text(isTimerActive ? "Pausar" : "Empezar")
                        .font(.headline)
                }
                .foregroundColor(.purple)
                .padding(.horizontal, 30)
                .padding(.vertical, 15)
                .background(Color.white)
                .cornerRadius(25)
            }
            
            // End Break Button
            Button(action: onBackToMain) {
                HStack {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                    Text("Terminar")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .padding(.vertical, 15)
                .background(Color.white.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                .cornerRadius(25)
            }
        }
        .padding(.bottom, 50)
    }
    
    // MARK: - Helper Properties
    
    private var progress: CGFloat {
        let totalTime: Double = 300 // 5 minutes
        return CGFloat(breakTimer) / CGFloat(totalTime)
    }
    
    // MARK: - Methods
    
    private func toggleTimer() {
        if isTimerActive {
            pauseTimer()
        } else {
            startTimer()
        }
    }
    
    private func startTimer() {
        isTimerActive = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if breakTimer > 0 {
                breakTimer -= 1
            } else {
                // Timer finished
                stopTimer()
                // TODO: Show completion notification
            }
        }
    }
    
    private func pauseTimer() {
        isTimerActive = false
        timer?.invalidate()
        timer = nil
    }
    
    private func stopTimer() {
        isTimerActive = false
        timer?.invalidate()
        timer = nil
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Tip Row

struct TipRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.cyan)
                .frame(width: 20)
            
            Text(text)
                .font(.body)
                .foregroundColor(.white)
            
            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    BreakScreen()
}
