import SwiftUI
import ElevenLabs

struct VoiceButtonView: View {
    let isConnected: Bool
    let agentState: AgentState
    let isMuted: Bool
    let onTap: () -> Void
    
    @State private var isPulsing = false
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Outer pulsing ring when connected (listening or speaking)
                if isConnected {
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: pulsingRingColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 4
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(isPulsing ? 1.2 : 1.0)
                        .opacity(isPulsing ? 0 : 1)
                        .animation(
                            Animation.easeInOut(duration: agentState == .speaking ? 1.5 : 2.5)
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
                    .frame(width: 120, height: 120)
                    .background(
                        // Glass blur effect
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 120, height: 120)
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
                    .shadow(color: Color(red: 0.64, green: 0.85, blue: 0.81).opacity(0.3), radius: 15, x: 0, y: 8) // #A2D9CE
                    .shadow(color: Color.black.opacity(0.1), radius: 30, x: 0, y: 15)
                
                // Icon (sin texto)
                Image(systemName: buttonIcon)
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            if isConnected {
                isPulsing = true
            }
        }
        .onChange(of: isConnected) { connected in
            isPulsing = connected
        }
        .onChange(of: agentState) { _ in
            // Keep pulsing while connected, just change the speed
            isPulsing = isConnected
        }
    }
    
    // MARK: - Computed Properties
    
    private var buttonGradientColors: [Color] {
        if !isConnected {
            // Desconectado: Gradiente sutil gris
            return [
                Color.gray.opacity(0.3),
                Color.gray.opacity(0.2)
            ]
        } else if isMuted {
            // Muteado: Gradiente rojo
            return [
                Color.red.opacity(0.5),
                Color.orange.opacity(0.4)
            ]
        } else if agentState == .speaking {
            // Hablando: Gradiente verde brillante
            return [
                Color(red: 0.64, green: 0.85, blue: 0.81).opacity(0.6), // #A2D9CE
                Color(red: 0.44, green: 0.68, blue: 0.88).opacity(0.5)  // #71ADE1
            ]
        } else {
            // Escuchando: Gradiente azul activo
            return [
                Color(red: 0.44, green: 0.68, blue: 0.88).opacity(0.5), // #71ADE1
                Color(red: 0.64, green: 0.85, blue: 0.81).opacity(0.4)  // #A2D9CE
            ]
        }
    }
    
    private var pulsingRingColors: [Color] {
        if agentState == .speaking {
            // Anillo verde cuando habla
            return [
                Color(red: 0.64, green: 0.85, blue: 0.81).opacity(0.6), // #A2D9CE
                Color(red: 0.44, green: 0.68, blue: 0.88).opacity(0.3)  // #71ADE1
            ]
        } else {
            // Anillo azul cuando escucha
            return [
                Color(red: 0.44, green: 0.68, blue: 0.88).opacity(0.4), // #71ADE1
                Color(red: 0.64, green: 0.85, blue: 0.81).opacity(0.2)  // #A2D9CE
            ]
        }
    }
    
    private var buttonShadowColor: Color {
        if !isConnected {
            return Color.gray.opacity(0.2)
        } else if agentState == .speaking {
            return Color(red: 0.64, green: 0.85, blue: 0.81).opacity(0.4) // #A2D9CE
        } else {
            return Color(red: 0.44, green: 0.68, blue: 0.88).opacity(0.4) // #71ADE1
        }
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

