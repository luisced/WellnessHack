import SwiftUI

/// Vista del timer circular con progreso y tiempo restante
struct TimerCircleView: View {
    let timeRemaining: TimeInterval
    let totalTime: TimeInterval
    let isActive: Bool
    
    private var progress: Double {
        guard totalTime > 0 else { return 0 }
        return (totalTime - timeRemaining) / totalTime
    }
    
    private var formattedTime: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.focusBlue.opacity(0.2), lineWidth: 8)
                .frame(width: 200, height: 200)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: [Color.focusBlue, Color.focusBlue.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(-90)) // Start from top
                .animation(.easeInOut(duration: 1.0), value: progress)
            
            // Inner circle with glass effect
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 160, height: 160)
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.4),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 160, height: 160)
                )
                .shadow(color: Color.focusBlue.opacity(0.3), radius: 15, x: 0, y: 8)
            
            // Time display
            VStack(spacing: 4) {
                Text(formattedTime)
                    .font(.system(size: 36, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                
                Text(isActive ? "FOCUS TIME" : "PAUSED")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.7))
                    .tracking(1.2)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.focusBackground.ignoresSafeArea()
        
        VStack(spacing: 40) {
            TimerCircleView(
                timeRemaining: 1500, // 25 minutes
                totalTime: 1500,
                isActive: true
            )
            
            TimerCircleView(
                timeRemaining: 900, // 15 minutes remaining
                totalTime: 1500, // of 25 minutes
                isActive: true
            )
            
            TimerCircleView(
                timeRemaining: 300, // 5 minutes remaining
                totalTime: 1500,
                isActive: false
            )
        }
    }
}
