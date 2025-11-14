import SwiftUI
import ElevenLabsSDK

struct VoiceButtonView: View {
    let isConnected: Bool
    let agentState: AgentState
    let isMuted: Bool
    let onTap: () -> Void
    
    @State private var isPulsing = false
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Outer pulsing ring when agent is speaking
                if isConnected && agentState == .speaking {
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(hex: "A2D9CE").opacity(0.4),
                                    Color(hex: "71ADE1").opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 4
                        )
                        .frame(width: 190, height: 190)
                        .scaleEffect(isPulsing ? 1.2 : 1.0)
                        .opacity(isPulsing ? 0 : 1)
                        .animation(
                            Animation.easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: false),
                            value: isPulsing
                        )
                }
                
                // Main button circle with glass effect
                Circle()
                    .fill(
                        LinearGradient(
                            colors: buttonGradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 160, height: 160)
                    .background(
                        // Glass blur effect
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 160, height: 160)
                    )
                    .overlay(
                        // Glass border
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.6),
                                        Color.white.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .shadow(color: Color(hex: "A2D9CE").opacity(0.3), radius: 15, x: 0, y: 8)
                    .shadow(color: Color.black.opacity(0.1), radius: 30, x: 0, y: 15)
                
                // Icon (sin texto)
                Image(systemName: buttonIcon)
                    .font(.system(size: 50, weight: .medium))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            if isConnected && agentState == .speaking {
                isPulsing = true
            }
        }
        .onChange(of: agentState) { newState in
            isPulsing = isConnected && newState == .speaking
        }
    }
    
    // MARK: - Computed Properties
    
    private var buttonGradientColors: [Color] {
        // Gradiente cristal: verde menta a azul cielo
        return [
            Color(hex: "A2D9CE").opacity(0.4),
            Color(hex: "71ADE1").opacity(0.3)
        ]
    }
    
    private var buttonShadowColor: Color {
        return Color(hex: "71ADE1").opacity(0.4)
    }
    
    private var buttonIcon: String {
        if !isConnected {
            return "mic.fill"
        } else if isMuted {
            return "mic.slash.fill"
        } else if agentState == .speaking {
            return "waveform"
        } else {
            return "mic.fill"
        }
    }
    
    // Texto removido - ya no se usa
}

// MARK: - Preview

#Preview {
    VStack(spacing: 40) {
        VoiceButtonView(
            isConnected: false,
            agentState: .listening,
            isMuted: false,
            onTap: {}
        )
        
        VoiceButtonView(
            isConnected: true,
            agentState: .listening,
            isMuted: false,
            onTap: {}
        )
        
        VoiceButtonView(
            isConnected: true,
            agentState: .speaking,
            isMuted: false,
            onTap: {}
        )
        
        VoiceButtonView(
            isConnected: true,
            agentState: .listening,
            isMuted: true,
            onTap: {}
        )
    }
}

