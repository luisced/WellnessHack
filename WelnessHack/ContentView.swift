import SwiftUI

struct ContentView: View {
    @State private var showSplash = true
    
    var body: some View {
        ZStack {
            MainTabView(splashCompleted: !showSplash)
                .zIndex(0)
            
            if showSplash {
                SplashScreen(isActive: $showSplash)
                    .transition(.opacity)
                    .zIndex(2)
            }
        }
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @State private var healthKitAuthorized = false
    @State private var showingHealthKitError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            List {
                // Environment Status
                Section("Estado de Configuración") {
                    ConfigStatusRow(
                        title: "API Key",
                        isConfigured: !ElevenLabsConfig.apiKey.isEmpty,
                        value: ElevenLabsConfig.apiKey.isEmpty ? "No configurado" : "Configurado ✓"
                    )
                    
                    ConfigStatusRow(
                        title: "Agent ID",
                        isConfigured: !ElevenLabsConfig.agentID.isEmpty,
                        value: ElevenLabsConfig.agentID.isEmpty ? "No configurado" : "Configurado ✓"
                    )
                }
                
                // HealthKit Permission
                Section("Permisos") {
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
                                    await requestHealthKitPermission()
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
                
                // Setup Instructions
                Section("Instrucciones de Configuración") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("1. Crear archivo .env")
                            .font(.headline)
                        Text("cp .env.example .env")
                            .font(.system(.caption, design: .monospaced))
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(4)
                        
                        Text("2. Agrega tus claves al .env")
                            .font(.headline)
                        Text("ELEVENLABS_API_KEY=your_key\nELEVENLABS_AGENT_ID=your_id")
                            .font(.system(.caption, design: .monospaced))
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(4)
                        
                        Text("3. Agrega .env a Xcode")
                            .font(.headline)
                        Text("Arrastra .env al proyecto Xcode\nMarca 'Copy items if needed'")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Link("📖 Guía Completa de Configuración", destination: URL(string: "https://github.com")!)
                            .font(.caption)
                    }
                    .padding(.vertical, 4)
                }
                
                // Quick Actions
                Section("Acciones Rápidas") {
                    Button(action: {
                        Task {
                            await testHealthKitData()
                        }
                    }) {
                        Label("Probar Datos de HealthKit", systemImage: "heart.text.square")
                    }
                    
                    Button(action: {
                        validateConfiguration()
                    }) {
                        Label("Validar Configuración", systemImage: "checkmark.shield")
                    }
                }
                
                // App Info
                Section("Acerca de") {
                    HStack {
                        Text("Versión")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Compilación")
                        Spacer()
                        Text("1")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Configuración")
            .task {
                await checkHealthKitStatus()
            }
            .alert("Error", isPresented: $showingHealthKitError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Actions
    
    private func requestHealthKitPermission() async {
        do {
            try await HealthKitManager.shared.requestAuthorization()
            healthKitAuthorized = true
            print("✅ HealthKit authorized")
        } catch {
            errorMessage = "Failed to authorize HealthKit: \(error.localizedDescription)"
            showingHealthKitError = true
            print("❌ HealthKit authorization failed: \(error)")
        }
    }
    
    private func checkHealthKitStatus() async {
        healthKitAuthorized = HealthKitManager.shared.isAuthorized
    }
    
    private func testHealthKitData() async {
        do {
            let manager = HealthKitManager.shared
            
            print("\n🧪 Testing HealthKit Data...")
            
            // Test sleep
            let sleep = try await manager.fetchLastNightSleep()
            print("💤 Sleep: \(sleep.durationHours)h, Quality: \(sleep.quality)/100")
            
            // Test HRV
            let hrv = try await manager.fetchAverageHRV()
            print("❤️ HRV: \(hrv ?? 0) ms")
            
            // Test activity
            let activity = try await manager.fetchActivitySummary()
            print("🏃 Steps: \(activity.steps), Calories: \(activity.activeCalories)")
            
            print("✅ HealthKit data test completed\n")
            
        } catch {
            errorMessage = "Failed to fetch HealthKit data: \(error.localizedDescription)"
            showingHealthKitError = true
            print("❌ HealthKit test failed: \(error)")
        }
    }
    
    private func validateConfiguration() {
        print("\n🔍 Validating Configuration...")
        
        // Check API Key
        if ElevenLabsConfig.apiKey.isEmpty {
            print("❌ ELEVENLABS_API_KEY is not set")
        } else {
            print("✅ ELEVENLABS_API_KEY is configured")
        }
        
        // Check Agent ID
        if ElevenLabsConfig.agentID.isEmpty {
            print("❌ ELEVENLABS_AGENT_ID is not set")
        } else {
            print("✅ ELEVENLABS_AGENT_ID is configured")
        }
        
        // Check HealthKit
        if healthKitAuthorized {
            print("✅ HealthKit is authorized")
        } else {
            print("⚠️ HealthKit is not authorized")
        }
        
        print("\n")
    }
}

// MARK: - Config Status Row

struct ConfigStatusRow: View {
    let title: String
    let isConfigured: Bool
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: isConfigured ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isConfigured ? .green : .red)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                Text(value)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    ContentView()
}
