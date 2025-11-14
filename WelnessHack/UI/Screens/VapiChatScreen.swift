import SwiftUI
import SplineRuntime

struct VapiChatScreen: View {
    @StateObject private var viewModel = VapiChatViewModel()
    
    var body: some View {
        ZStack {
            // MARK: - Spline 3D Animated Background
            
            if let url = Bundle.main.url(
                forResource: "abstract_gradient_background_copy",
                withExtension: "splineswift"
            ) {
                SplineView(sceneFileURL: url)
                    .ignoresSafeArea()
            } else {
                // Fallback gradient if Spline file not found
                LinearGradient(
                    colors: [
                        Color(red: 0.1, green: 0.3, blue: 0.9).opacity(0.8),
                        Color(red: 0.5, green: 0.2, blue: 0.8).opacity(0.6),
                        Color(red: 0.9, green: 0.1, blue: 0.5).opacity(0.4)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }
            
            // MARK: - Content Overlay
            
            VStack(spacing: 0) {
                // Top spacing
                Spacer()
                    .frame(height: 100)
                
                // MARK: - Chatbot Avatar
                AvatarView(
                    isActive: viewModel.isBotSpeaking,
                    imageURL: viewModel.avatarImageURL
                )
                
                Spacer()
                    .frame(height: 80)
                
                // MARK: - Audio Waveform (cuando el bot habla)
                AudioWaveformView(isAnimating: viewModel.isBotSpeaking)
                    .frame(height: 80)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                // MARK: - Voice Button (Micrófono)
                VoiceButtonView(
                    isConnected: viewModel.isConnected,
                    agentState: viewModel.isBotSpeaking ? .speaking : .listening,
                    isMuted: false,
                    onTap: {
                        Task {
                            await viewModel.toggleChatSession()
                        }
                    }
                )
                .padding(.bottom, 80)
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

// MARK: - Preview

#Preview {
    VapiChatScreen()
}

#Preview("Connected - Bot Speaking") {
    let viewModel = VapiChatViewModel()
    VapiChatScreen()
        .onAppear {
            Task {
                await viewModel.startChatSession()
                viewModel.simulateBotSpeaking()
            }
        }
}

#Preview("Connected - Listening") {
    let viewModel = VapiChatViewModel()
    VapiChatScreen()
        .onAppear {
            Task {
                await viewModel.startChatSession()
            }
        }
}
