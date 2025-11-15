import SwiftUI
import ElevenLabs

struct EnergyCoachView: View {
    @StateObject private var viewModel = EnergyCoachViewModel()
    @State private var showingPermissions = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Energy Dashboard
                    EnergyDashboardView(
                        bodyBattery: viewModel.currentBodyBattery,
                        sleepData: viewModel.sleepData,
                        activityData: viewModel.activityData
                    )
                    .padding(.horizontal)
                    
                    // Chat Messages
                    if viewModel.isConnected {
                        ChatMessagesView(messages: viewModel.messages)
                            .frame(maxHeight: 300)
                    }
                    
                    Spacer()
                    
                    // Voice Button & Controls
                    VStack(spacing: 16) {
                        // Connection status
                        Text(viewModel.connectionStatus)
                            .font(.caption)
                            .foregroundColor(viewModel.isConnected ? .green : .gray)
                        
                        // Main voice button
                        VoiceButtonView(
                            isConnected: viewModel.isConnected,
                            agentState: viewModel.agentState,
                            isMuted: viewModel.isMuted,
                            onTap: {
                                Task {
                                    await viewModel.toggleConversation()
                                }
                            }
                        )
                        
                        // Control buttons
                        if viewModel.isConnected {
                            HStack(spacing: 20) {
                                Button(action: {
                                    Task {
                                        await viewModel.toggleMute()
                                    }
                                }) {
                                    Image(systemName: viewModel.isMuted ? "mic.slash.fill" : "mic.fill")
                                        .font(.title2)
                                        .foregroundColor(viewModel.isMuted ? .red : .blue)
                                }
                                
                                Button(action: {
                                    Task {
                                        await viewModel.sendTestMessage()
                                    }
                                }) {
                                    Image(systemName: "text.bubble.fill")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Energy Coach")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingPermissions = true
                    }) {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showingPermissions) {
                PermissionsView()
            }
            .task {
                await viewModel.initialize()
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

// MARK: - Chat Messages View

struct ChatMessagesView: View {
    let messages: [ConversationMessage]
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(messages, id: \.id) { message in
                        MessageBubble(message: message)
                            .id(message.id)
                    }
                }
                .padding()
            }
            .onChange(of: messages.count) { _ in
                if let lastMessage = messages.last {
                    withAnimation {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
        .background(Color.white.opacity(0.5))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

struct MessageBubble: View {
    let message: ConversationMessage
    
    var body: some View {
        HStack {
            if message.role == .user { Spacer() }
            
            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                Text(message.role == .user ? "Tú" : "Coach")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(message.content)
                    .padding(12)
                    .background(message.role == .user ? Color.blue : Color.gray.opacity(0.3))
                    .foregroundColor(message.role == .user ? .white : .primary)
                    .cornerRadius(16)
            }
            .frame(maxWidth: 280, alignment: message.role == .user ? .trailing : .leading)
            
            if message.role == .assistant { Spacer() }
        }
    }
}

// MARK: - Permissions View

struct PermissionsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var healthKitAuthorized = false
    
    var body: some View {
        NavigationView {
            List {
                Section("Permisos de Salud") {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                        Text("HealthKit")
                        Spacer()
                        if healthKitAuthorized {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        } else {
                            Button("Autorizar") {
                                Task {
                                    try? await HealthKitManager.shared.requestAuthorization()
                                    healthKitAuthorized = true
                                }
                            }
                        }
                    }
                }
                
                Section("Configuración de ElevenLabs") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Agent ID")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(ElevenLabsConfig.agentID.isEmpty ? "No configurado" : ElevenLabsConfig.agentID)
                            .font(.system(.body, design: .monospaced))
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("API Key")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(ElevenLabsConfig.apiKey.isEmpty ? "No configurado" : "••••••••")
                            .font(.system(.body, design: .monospaced))
                    }
                }
                
                Section {
                    Text("Configura las variables de entorno ELEVENLABS_API_KEY y ELEVENLABS_AGENT_ID")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Configuración")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    EnergyCoachView()
}

