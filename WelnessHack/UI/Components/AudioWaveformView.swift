import SwiftUI

/// Vista de barras de audio animadas que representan cuando el bot está hablando
struct AudioWaveformView: View {
    let isAnimating: Bool
    let barCount: Int = 5
    
    @State private var amplitudes: [CGFloat] = []
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            ForEach(0..<barCount, id: \.self) { index in
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: isAnimating ? 
                                [Color(red: 1.0, green: 0.6, blue: 0.5), Color(red: 0.9, green: 0.4, blue: 0.3)] :
                                [Color.gray.opacity(0.3), Color.gray.opacity(0.2)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 6, height: barHeight(for: index))
                    .animation(
                        isAnimating ?
                            Animation.easeInOut(duration: randomDuration(for: index))
                                .repeatForever(autoreverses: true) :
                            .default,
                        value: amplitudes
                    )
            }
        }
        .frame(height: 60)
        .onAppear {
            initializeAmplitudes()
            if isAnimating {
                startAnimating()
            }
        }
        .onChange(of: isAnimating) { newValue in
            if newValue {
                startAnimating()
            } else {
                stopAnimating()
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func initializeAmplitudes() {
        amplitudes = (0..<barCount).map { _ in
            isAnimating ? CGFloat.random(in: 0.3...1.0) : 0.3
        }
    }
    
    private func startAnimating() {
        withAnimation {
            amplitudes = (0..<barCount).map { _ in
                CGFloat.random(in: 0.4...1.0)
            }
        }
    }
    
    private func stopAnimating() {
        withAnimation {
            amplitudes = (0..<barCount).map { _ in 0.3 }
        }
    }
    
    private func barHeight(for index: Int) -> CGFloat {
        let baseHeight: CGFloat = 20
        let maxHeight: CGFloat = 60
        
        guard index < amplitudes.count else {
            return baseHeight
        }
        
        return isAnimating ? 
            baseHeight + (maxHeight - baseHeight) * amplitudes[index] :
            baseHeight
    }
    
    private func randomDuration(for index: Int) -> Double {
        // Diferentes duraciones para cada barra para efecto más natural
        let baseDuration = 0.6
        let variation = Double(index) * 0.1
        return baseDuration + variation
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack(spacing: 60) {
            VStack(spacing: 8) {
                Text("Idle")
                    .foregroundColor(.white)
                    .font(.caption)
                AudioWaveformView(isAnimating: false)
            }
            
            VStack(spacing: 8) {
                Text("Speaking")
                    .foregroundColor(.white)
                    .font(.caption)
                AudioWaveformView(isAnimating: true)
            }
        }
    }
}
