import Foundation
import SwiftUI
import ElevenLabs
import Combine

@MainActor
class EnergyCoachViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var isConnected = false
    @Published var isMuted = false
    @Published var agentState: AgentState = .listening
    @Published var connectionStatus = "Desconectado"
    @Published var messages: [ConversationMessage] = []
    
    @Published var currentBodyBattery: BodyBatterySnapshot?
    @Published var sleepData: SleepData?
    @Published var activityData: ActivityData?
    
    @Published var showError = false
    @Published var errorMessage = ""
    
    // MARK: - Private Properties
    
    private let elevenLabsClient = ElevenLabsClient()
    private let healthKitManager = HealthKitManager.shared
    private let bodyBatteryCalculator = BodyBatteryCalculator()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() {
        setupObservers()
    }
    
    // MARK: - Setup
    
    private func setupObservers() {
        // Observe ElevenLabs client state
        elevenLabsClient.$isConnected
            .assign(to: &$isConnected)
        
        elevenLabsClient.$isMuted
            .assign(to: &$isMuted)
        
        elevenLabsClient.$agentState
            .assign(to: &$agentState)
        
        elevenLabsClient.$connectionStatus
            .assign(to: &$connectionStatus)
        
        elevenLabsClient.$messages
            .assign(to: &$messages)
    }
    
    func initialize() async {
        do {
            // Request HealthKit authorization
            if !healthKitManager.isAuthorized {
                try await healthKitManager.requestAuthorization()
            }
            
            // Fetch initial health data
            await refreshHealthData()
            
        } catch {
            showError(message: "Error al inicializar: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Health Data
    
    func refreshHealthData() async {
        do {
            // Fetch health data
            sleepData = try await healthKitManager.fetchLastNightSleep()
            let hrvAverage = try await healthKitManager.fetchAverageHRV()
            activityData = try await healthKitManager.fetchActivitySummary()
            
            // Calculate body battery
            currentBodyBattery = bodyBatteryCalculator.calculateBodyBattery(
                sleepData: sleepData,
                hrvAverage: hrvAverage,
                activityData: activityData
            )
            
            print("✅ Health data refreshed")
            print("Body Battery: \(currentBodyBattery?.score ?? 0)/100")
            
        } catch {
            print("⚠️ Error fetching health data: \(error)")
            // Don't show error to user, just use default values
        }
    }
    
    // MARK: - Conversation Control
    
    func toggleConversation() async {
        if isConnected {
            await endConversation()
        } else {
            await startConversation()
        }
    }
    
    func startConversation() async {
        do {
            // Ensure we have fresh health data
            await refreshHealthData()
            
            guard let bodyBattery = currentBodyBattery else {
                showError(message: "No se pudo obtener datos de salud")
                return
            }
            
            // Create conversation context
            let context = await ConversationContext.create(
                from: bodyBattery,
                sleepData: sleepData,
                activityData: activityData
            )
            
            // Start conversation with ElevenLabs
            try await elevenLabsClient.startConversation(with: context)
            
            print("🎙️ Conversation started")
            
        } catch {
            showError(message: "Error al iniciar conversación: \(error.localizedDescription)")
        }
    }
    
    func endConversation() async {
        await elevenLabsClient.endConversation()
        print("👋 Conversation ended")
    }
    
    // MARK: - Audio Controls
    
    func toggleMute() async {
        do {
            try await elevenLabsClient.toggleMute()
        } catch {
            showError(message: "Error al cambiar micrófono: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Messaging
    
    func sendTestMessage() async {
        do {
            try await elevenLabsClient.sendMessage("¿Cómo está mi nivel de energía?")
        } catch {
            showError(message: "Error al enviar mensaje: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Error Handling
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}

