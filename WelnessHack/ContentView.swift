import SwiftUI

struct ContentView: View {
    @State private var showSplash = true
    
    var body: some View {
        ZStack {
            // Pantalla principal
            MainTabView(splashCompleted: !showSplash)
                .zIndex(0)
            
            // Pantalla de carga superpuesta
            if showSplash {
                SplashScreen(isActive: $showSplash)
                    .transition(.opacity)
                    .zIndex(2)
            }
        }
    }
}

// MARK: - Legacy TabView (commented out for reference)
/*
struct ContentView_Legacy: View {
    var body: some View {
        TabView {
            EnergyCoachView()
                .tabItem {
                    Label("Coach", systemImage: "waveform.circle.fill")
                }
            
            CalendarScreen()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
            
            FocusScreen(isBreakActive: .constant(false))
                .tabItem {
                    Label("Focus", systemImage: "timer")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}
*/

// MARK: - Settings View

struct SettingsView: View {
    @State private var healthKitAuthorized = false
    @State private var showingHealthKitError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            List {
                // Environment Status
                Section("Configuration Status") {
                    ConfigStatusRow(
                        title: "API Key",
                        isConfigured: !ElevenLabsConfig.apiKey.isEmpty,
                        value: ElevenLabsConfig.apiKey.isEmpty ? "Not configured" : "Configured ✓"
                    )
                    
                    ConfigStatusRow(
                        title: "Agent ID",
                        isConfigured: !ElevenLabsConfig.agentID.isEmpty,
                        value: ElevenLabsConfig.agentID.isEmpty ? "Not configured" : "Configured ✓"
                    )
                }
                
                // HealthKit Permission
                Section("Permissions") {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                        Text("HealthKit")
                        Spacer()
                        if healthKitAuthorized {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        } else {
                            Button("Authorize") {
                                Task {
                                    await requestHealthKitPermission()
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
                
                // Setup Instructions
                Section("Setup Instructions") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("1. Create .env file")
                            .font(.headline)
                        Text("cp .env.example .env")
                            .font(.system(.caption, design: .monospaced))
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(4)
                        
                        Text("2. Add your keys to .env")
                            .font(.headline)
                        Text("ELEVENLABS_API_KEY=your_key\nELEVENLABS_AGENT_ID=your_id")
                            .font(.system(.caption, design: .monospaced))
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(4)
                        
                        Text("3. Add .env to Xcode")
                            .font(.headline)
                        Text("Drag .env to Xcode project\nMark 'Copy items if needed'")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Link("📖 Full Setup Guide", destination: URL(string: "https://github.com")!)
                            .font(.caption)
                    }
                    .padding(.vertical, 4)
                }
                
                // Quick Actions
                Section("Quick Actions") {
                    Button(action: {
                        Task {
                            await testHealthKitData()
                        }
                    }) {
                        Label("Test HealthKit Data", systemImage: "heart.text.square")
                    }
                    
                    Button(action: {
                        validateConfiguration()
                    }) {
                        Label("Validate Configuration", systemImage: "checkmark.shield")
                    }
                }
                
                // App Info
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
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
