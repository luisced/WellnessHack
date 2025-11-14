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
                // Outer pulsing ring when agent is speaking
                if isConnected && agentState == .speaking {
                    Circle()
                        .stroke(Color.blue.opacity(0.3), lineWidth: 4)
                        .frame(width: 140, height: 140)
                        .scaleEffect(isPulsing ? 1.2 : 1.0)
                        .opacity(isPulsing ? 0 : 1)
                        .animation(
                            Animation.easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: false),
                            value: isPulsing
                        )
                }
                
                // Main button circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: buttonGradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: buttonShadowColor, radius: 20, x: 0, y: 10)
                
                // Icon
                VStack(spacing: 8) {
                    Image(systemName: buttonIcon)
                        .font(.system(size: 40, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text(buttonText)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.9))
                }
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
        if !isConnected {
            return [Color.blue, Color.purple]
        } else if isMuted {
            return [Color.red.opacity(0.7), Color.orange.opacity(0.7)]
        } else if agentState == .speaking {
            return [Color.green, Color.blue]
        } else {
            return [Color.blue, Color.cyan]
        }
    }
    
    private var buttonShadowColor: Color {
        if !isConnected {
            return Color.blue.opacity(0.5)
        } else if agentState == .speaking {
            return Color.green.opacity(0.5)
        } else {
            return Color.blue.opacity(0.5)
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
    
    private var buttonText: String {
        if !isConnected {
            return "Iniciar"
        } else if agentState == .speaking {
            return "Hablando..."
        } else {
            return "Escuchando"
        }
    }
}

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

