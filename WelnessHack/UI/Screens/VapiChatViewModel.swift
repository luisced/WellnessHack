import Foundation
import SwiftUI
import Combine
import ElevenLabs

/// ViewModel para manejar el estado y lógica del chat con ElevenLabs
@MainActor
class VapiChatViewModel: ObservableObject {
    
    // MARK: - Published Properties (UI State)
    
    /// Indica si hay una sesión activa de chat
    @Published var isConnected: Bool = false
    
    /// Indica si el bot está hablando actualmente
    @Published var isBotSpeaking: Bool = false
    
    /// Indica si el usuario está hablando
    @Published var isUserSpeaking: Bool = false
    
    /// Estado actual de la conversación
    @Published var chatState: ChatState = .idle
    
    /// Mensajes de la conversación
    @Published var messages: [ChatMessage] = []
    
    /// Texto del estado de conexión para mostrar al usuario
    @Published var connectionStatusText: String = "Desconectado"
    
    /// URL del avatar del chatbot (opcional)
    @Published var avatarImageURL: String? = nil
    
    /// Indica si hay un error
    @Published var showError: Bool = false
    
    /// Mensaje de error para mostrar
    @Published var errorMessage: String = ""
    
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
            .sink { [weak self] connected in
                self?.isConnected = connected
                self?.connectionStatusText = connected ? "Conectado" : "Desconectado"
            }
            .store(in: &cancellables)
        
        elevenLabsClient.$agentState
            .sink { [weak self] state in
                self?.isBotSpeaking = (state == .speaking)
                self?.chatState = (state == .speaking) ? .botSpeaking : .listening
            }
            .store(in: &cancellables)
        
        elevenLabsClient.$messages
            .sink { [weak self] elevenLabsMessages in
                self?.updateMessages(from: elevenLabsMessages)
            }
            .store(in: &cancellables)
    }
    
    private func updateMessages(from elevenLabsMessages: [Message]) {
        messages = elevenLabsMessages.map { message in
            ChatMessage(
                id: UUID(),
                text: message.content,
                isUser: message.role == .user,
                timestamp: Date()
            )
        }
    }
    
    // MARK: - Public Methods
    
    /// Inicia o detiene la sesión de chat según el estado actual
    func toggleChatSession() async {
        if isConnected {
            await endChatSession()
        } else {
            await startChatSession()
        }
    }
    
    /// Inicia una nueva sesión de chat con el bot
    func startChatSession() async {
        chatState = .connecting
        connectionStatusText = "Conectando..."
        
        do {
            // 1. Obtener datos de salud para contexto
            let sleepData = try? await healthKitManager.fetchLastNightSleep()
            let hrvAverage = try? await healthKitManager.fetchAverageHRV()
            let activityData = try? await healthKitManager.fetchActivitySummary()
            
            // 2. Calcular Body Battery
            let bodyBattery = bodyBatteryCalculator.calculateBodyBattery(
                sleepData: sleepData,
                hrvAverage: hrvAverage,
                activityData: activityData
            )
            
            // 3. Crear contexto de conversación
            let context = await ConversationContext.create(
                from: bodyBattery,
                sleepData: sleepData,
                activityData: activityData
            )
            
            // 4. Iniciar conversación con ElevenLabs
            try await elevenLabsClient.startConversation(with: context)
            
            // 5. Actualizar UI
            chatState = .listening
            connectionStatusText = "Conectado - Habla ahora"
            
            print("🎤 Sesión de chat iniciada con ElevenLabs")
            print("📊 Body Battery: \(bodyBattery.score)/100")
            
        } catch {
            handleError(error)
        }
    }
    
    /// Finaliza la sesión de chat actual
    func endChatSession() async {
        chatState = .disconnecting
        connectionStatusText = "Desconectando..."
        
        await elevenLabsClient.endConversation()
        
        // Limpiar estado
        chatState = .idle
        connectionStatusText = "Desconectado"
        
        print("🔌 Sesión de chat finalizada")
    }
    
    /// Envía un mensaje de texto al agente
    func sendMessage(_ text: String) async {
        do {
            try await elevenLabsClient.sendMessage(text)
        } catch {
            handleError(error)
        }
    }
    
    /// Alterna el estado del micrófono (mute/unmute)
    func toggleMute() async {
        do {
            try await elevenLabsClient.toggleMute()
        } catch {
            handleError(error)
        }
    }
    
    /// Simula que el bot empieza a hablar (para testing UI)
    func simulateBotSpeaking() {
        isBotSpeaking = true
        chatState = .botSpeaking
        
        // Detener después de 3 segundos
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            isBotSpeaking = false
            chatState = .listening
        }
    }
    
    // MARK: - Private Methods
    
    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true
        isConnected = false
        chatState = .error
        connectionStatusText = "Error"
        print("❌ Error: \(error.localizedDescription)")
    }
}

// MARK: - Supporting Types

/// Estados posibles de la conversación
enum ChatState {
    case idle           // No conectado
    case connecting     // Conectando...
    case listening      // Usuario puede hablar
    case userSpeaking   // Usuario está hablando
    case botThinking    // Bot procesando
    case botSpeaking    // Bot está hablando
    case disconnecting  // Desconectando...
    case error          // Error
}

/// Modelo de mensaje de chat
struct ChatMessage: Identifiable {
    let id: UUID
    let text: String
    let isUser: Bool
    let timestamp: Date
}

// MARK: - ElevenLabs Integration Notes

/*
 ✅ INTEGRACIÓN COMPLETA CON ELEVENLABS
 
 El ViewModel ahora usa ElevenLabsClient que proporciona:
 
 1. ✅ Conexión con ElevenLabs Agent API
    - SDK oficial de ElevenLabs v2.0
    - Manejo automático de WebRTC para audio
    - Estados reactivos (@Published)
 
 2. ✅ Client Tools implementadas:
    - get_current_energy_score
    - get_energy_forecast
    - get_sleep_analysis
    - get_activity_summary
    - recommend_actions
 
 3. ✅ Contexto de conversación:
    - Body Battery score actual
    - Datos de sueño, HRV y actividad
    - Información temporal (hora del día, día de semana)
 
 4. ✅ Configuración:
    - Variables de entorno en .env
    - ELEVENLABS_API_KEY
    - ELEVENLABS_AGENT_ID
 
 5. ✅ Permisos configurados:
    - NSMicrophoneUsageDescription
    - NSHealthShareUsageDescription
    - NSHealthUpdateUsageDescription
 
 Para configurar el agente en ElevenLabs:
 - Ver docs/ELEVENLABS_SETUP.md
 */
