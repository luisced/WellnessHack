import SwiftUI

// Color extensions already exist in ClockView.swift

/// Vista de las frases motivacionales en bubbles verdes
struct MotivationalBubbleView: View {
    let message: String
    let isVisible: Bool
    
    var body: some View {
        HStack {
            Spacer()
            
            Text(message)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color.focusBlue)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.motivationalGreen.opacity(0.8),
                                    Color.motivationalGreen.opacity(0.6)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.3),
                                            Color.white.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: Color.motivationalGreen.opacity(0.3), radius: 10, x: 0, y: 5)
                )
            
            Spacer()
        }
        .opacity(isVisible ? 1 : 0)
        .scaleEffect(isVisible ? 1 : 0.8)
        .animation(.easeInOut(duration: 0.5), value: isVisible)
    }
}

/// Contenedor para múltiples frases motivacionales con rotación automática
struct MotivationalMessagesView: View {
    let messages: [String]
    @State private var currentMessageIndex = 0
    @State private var showMessage = true
    
    // Timer para rotar mensajes cada 8 segundos (más tiempo)
    private let messageTimer = Timer.publish(every: 8.0, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 20) {
            // Solo una frase
            if messages.indices.contains(currentMessageIndex) {
                MotivationalBubbleView(
                    message: messages[currentMessageIndex],
                    isVisible: showMessage
                )
            }
        }
        .onReceive(messageTimer) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                showMessage = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                currentMessageIndex = (currentMessageIndex + 1) % messages.count
                
                withAnimation(.easeInOut(duration: 0.5)) {
                    showMessage = true
                }
            }
        }
        .onAppear {
            showMessage = true
        }
    }
}

// MARK: - Motivational Messages Data

struct MotivationalMessages {
    static let focusMessages = [
        "You're doing great! Keep going.",
        "Focus is your superpower.",
        "Every minute counts towards your goals.",
        "Deep breaths. You've got this.",
        "Productivity flows when you're in the zone.",
        "Your future self will thank you.",
        "Stay present, stay focused.",
        "Great things take time and focus.",
        "You're building something amazing.",
        "Consistency is key to success."
    ]
    
    static let breakMessages = [
        "Time to recharge your mind.",
        "A good break leads to better focus.",
        "Rest is productive too.",
        "Take a moment to breathe.",
        "You've earned this break.",
        "Stretch, hydrate, and reset.",
        "Short breaks, long-term gains.",
        "Your brain needs this pause.",
        "Refresh to perform better.",
        "Balance is the key to productivity."
    ]
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.focusBackground.ignoresSafeArea()
        
        VStack(spacing: 60) {
            // Single bubble
            MotivationalBubbleView(
                message: "You're doing great! Keep going.",
                isVisible: true
            )
            
            // Rotating messages
            MotivationalMessagesView(
                messages: MotivationalMessages.focusMessages
            )
        }
        .padding()
    }
}
