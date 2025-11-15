import SwiftUI
import Combine

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
        "¡Lo estás haciendo genial! Sigue así.",
        "El enfoque es tu superpoder.",
        "Cada minuto cuenta para tus metas.",
        "Respira profundo. Tú puedes.",
        "La productividad fluye en la zona.",
        "Tu yo del futuro te lo agradecerá.",
        "Mantente presente, mantente enfocado.",
        "Las grandes cosas toman tiempo y enfoque.",
        "Estás construyendo algo increíble.",
        "La consistencia es clave para el éxito."
    ]
    
    static let breakMessages = [
        "Hora de recargar tu mente.",
        "Un buen descanso lleva a mejor enfoque.",
        "El descanso también es productivo.",
        "Tómate un momento para respirar.",
        "Te has ganado este descanso.",
        "Estírate, hidrátate y reiníciate.",
        "Descansos cortos, ganancias a largo plazo.",
        "Tu cerebro necesita esta pausa.",
        "Refréscate para rendir mejor.",
        "El equilibrio es clave para la productividad."
    ]
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.focusBackground.ignoresSafeArea()
        
        VStack(spacing: 60) {
            // Single bubble
            MotivationalBubbleView(
                message: "¡Lo estás haciendo genial! Sigue así.",
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
