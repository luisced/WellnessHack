import SwiftUI
import SplineRuntime
import HealthKit

struct VapiChatScreen: View {
    @StateObject private var viewModel = VapiChatViewModel()
    @State private var showPermissionsAlert = false
    @State private var permissionsGranted = false
    
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
            await checkAndRequestPermissions()
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
