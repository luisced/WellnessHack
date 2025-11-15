import SwiftUI
import SplineRuntime
import HealthKit

struct VapiChatScreen: View {
    let splashCompleted: Bool
    
    @StateObject private var viewModel = VapiChatViewModel()
    @State private var showPermissionsAlert = false
    @State private var permissionsGranted = false
    @State private var messageText = ""
    @State private var showChatInput = false
    
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
                
                // MARK: - Chat Messages (if connected)
                if viewModel.isConnected && !viewModel.messages.isEmpty {
                    ChatMessagesScrollView(messages: viewModel.messages)
                        .frame(maxHeight: 200)
                        .padding(.horizontal, 20)
                }
                
                Spacer()
                
                // MARK: - Text Input (if connected and chat visible)
                if viewModel.isConnected && showChatInput {
                    HStack(spacing: 12) {
                        TextField("Escribe un mensaje...", text: $messageText)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white.opacity(0.2))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                            .foregroundColor(.white)
                            .submitLabel(.send)
                            .onSubmit {
                                sendTextMessage()
                            }
                        
                        Button(action: sendTextMessage) {
                            Image(systemName: "paperplane.fill")
                                .font(.title3)
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color(red: 0.44, green: 0.68, blue: 0.88),
                                                    Color(red: 0.64, green: 0.85, blue: 0.81)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .shadow(color: Color(red: 0.44, green: 0.68, blue: 0.88).opacity(0.4), radius: 10)
                                )
                        }
                        .disabled(messageText.isEmpty)
                        .opacity(messageText.isEmpty ? 0.5 : 1.0)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                // MARK: - Voice Button & Controls
                VStack(spacing: 16) {
                    // Main Voice Button
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
                    
                    // Connection Status Indicator
                    if viewModel.isConnected {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(viewModel.isBotSpeaking ? Color.green : Color.blue)
                                .frame(width: 8, height: 8)
                            
                            Text(viewModel.isBotSpeaking ? "🗣️ Hablando..." : "🎤 Escuchando...")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.3))
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                        
                        // Chat Toggle Button
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                showChatInput.toggle()
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: showChatInput ? "keyboard.chevron.compact.down" : "text.bubble.fill")
                                    .font(.caption)
                                Text(showChatInput ? "Ocultar Chat" : "Mostrar Chat")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.44, green: 0.68, blue: 0.88).opacity(0.3),
                                                Color(red: 0.64, green: 0.85, blue: 0.81).opacity(0.3)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                    } else {
                        Text("Toca para iniciar")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.bottom, 140) // Aumentado para no estar tapado por tab bar
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .alert("Permisos de Salud Requeridos", isPresented: $showPermissionsAlert) {
            Button("Autorizar") {
                Task {
                    await requestHealthKitPermissions()
                }
            }
            Button("Cancelar", role: .cancel) {
                showPermissionsAlert = false
            }
        } message: {
            Text("Necesitamos acceso a tus datos de salud (sueño, HRV, actividad) para calcular tu nivel de energía y darte recomendaciones personalizadas.")
        }
        .task {
            // Solo solicitar permisos después de que el splash haya terminado
            if splashCompleted {
                await checkAndRequestPermissions()
            }
        }
        .onChange(of: splashCompleted) { _, newValue in
            // Solicitar permisos cuando el splash termine
            if newValue && !permissionsGranted {
                Task {
                    await checkAndRequestPermissions()
                }
            }
        }
    }
    
    // MARK: - Health Permissions
    
    private func checkAndRequestPermissions() async {
        // Check if HealthKit is available
        guard HKHealthStore.isHealthDataAvailable() else {
            print("⚠️ HealthKit not available on this device")
            return
        }
        
        // Check if already authorized
        let healthKitManager = HealthKitManager.shared
        if healthKitManager.isAuthorized {
            permissionsGranted = true
            print("✅ HealthKit already authorized")
            return
        }
        
        // Show permissions alert
        showPermissionsAlert = true
    }
    
    private func requestHealthKitPermissions() async {
        do {
            try await HealthKitManager.shared.requestAuthorization()
            permissionsGranted = true
            print("✅ HealthKit permissions granted")
        } catch {
            viewModel.errorMessage = "No se pudieron obtener los permisos de HealthKit: \(error.localizedDescription)"
            viewModel.showError = true
            print("❌ HealthKit authorization failed: \(error)")
        }
    }
    
    private func sendTextMessage() {
        guard !messageText.isEmpty else { return }
        
        Task {
            await viewModel.sendMessage(messageText)
            messageText = ""
            // Hide keyboard
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

// MARK: - Chat Messages Scroll View

struct ChatMessagesScrollView: View {
    let messages: [ChatMessage]
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(messages) { message in
                        ChatMessageBubble(message: message)
                            .id(message.id)
                    }
                }
                .padding()
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .onChange(of: messages.count) { _ in
                if let lastMessage = messages.last {
                    withAnimation {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
}

struct ChatMessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.isUser ? "Tú" : "Coach")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
                
                Text(message.text)
                    .font(.body)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                message.isUser
                                ? LinearGradient(
                                    colors: [Color.blue, Color.cyan],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                : LinearGradient(
                                    colors: [Color.white.opacity(0.2), Color.white.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .foregroundColor(.white)
            }
            .frame(maxWidth: 280, alignment: message.isUser ? .trailing : .leading)
            
            if !message.isUser { Spacer() }
        }
    }
}

// MARK: - Preview

#Preview {
    VapiChatScreen(splashCompleted: true)
}

#Preview("Connected - Bot Speaking") {
    let viewModel = VapiChatViewModel()
    VapiChatScreen(splashCompleted: true)
        .onAppear {
            Task {
                await viewModel.startChatSession()
                viewModel.simulateBotSpeaking()
            }
        }
}

#Preview("Connected - Listening") {
    let viewModel = VapiChatViewModel()
    VapiChatScreen(splashCompleted: true)
        .onAppear {
            Task {
                await viewModel.startChatSession()
            }
        }
}
