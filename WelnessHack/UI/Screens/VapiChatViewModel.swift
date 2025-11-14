import Foundation
import SwiftUI
import Combine

/// ViewModel para manejar el estado y lógica del VapiChatScreen
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
    
    /// Mensajes de la conversación (para futuras implementaciones)
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
    
    private var cancellables = Set<AnyCancellable>()
    
    // TODO: BACKEND - Agregar VapiClient cuando se implemente
    // private var vapiClient: VapiClient?
    
    // TODO: BACKEND - Agregar AudioManager para manejar el micrófono
    // private var audioManager: AudioManager?
    
    // MARK: - Initialization
    
    init() {
        setupMockData()
    }
    
    // MARK: - Mock Data (Para UI Testing)
    
    private func setupMockData() {
        // Avatar placeholder
        avatarImageURL = nil // Cuando se implemente, usar URL real
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
        
        // TODO: BACKEND - Implementar conexión con Vapi
        /*
        do {
            // 1. Configurar permisos de audio
            try await requestMicrophonePermission()
            
            // 2. Inicializar VapiClient
            vapiClient = VapiClient(
                publicKey: VapiConfig.publicKey,
                assistantId: VapiConfig.assistantId
            )
            
            // 3. Configurar callbacks
            vapiClient?.onSpeechStart = { [weak self] in
                Task { @MainActor in
                    self?.isBotSpeaking = true
                }
            }
            
            vapiClient?.onSpeechEnd = { [weak self] in
                Task { @MainActor in
                    self?.isBotSpeaking = false
                }
            }
            
            vapiClient?.onTranscript = { [weak self] text in
                Task { @MainActor in
                    self?.addMessage(text: text, isUser: false)
                }
            }
            
            vapiClient?.onError = { [weak self] error in
                Task { @MainActor in
                    self?.handleError(error)
                }
            }
            
            // 4. Iniciar sesión
            try await vapiClient?.startSession()
            
            // 5. Actualizar UI
            isConnected = true
            chatState = .listening
            connectionStatusText = "Conectado - Habla ahora"
            
        } catch {
            handleError(error)
        }
        */
        
        // MOCK: Simular conexión exitosa para probar UI
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 segundo
        isConnected = true
        chatState = .listening
        connectionStatusText = "Conectado - Habla ahora"
        print("🎤 [MOCK] Sesión de chat iniciada")
    }
    
    /// Finaliza la sesión de chat actual
    func endChatSession() async {
        chatState = .disconnecting
        connectionStatusText = "Desconectando..."
        
        // TODO: BACKEND - Implementar desconexión
        /*
        do {
            try await vapiClient?.endSession()
            vapiClient = nil
            
            // Limpiar estado
            isConnected = false
            isBotSpeaking = false
            isUserSpeaking = false
            chatState = .idle
            connectionStatusText = "Desconectado"
            
        } catch {
            handleError(error)
        }
        */
        
        // MOCK: Simular desconexión
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 segundos
        isConnected = false
        isBotSpeaking = false
        isUserSpeaking = false
        chatState = .idle
        connectionStatusText = "Desconectado"
        print("🔌 [MOCK] Sesión de chat finalizada")
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
    
    /// Simula que el usuario empieza a hablar (para testing UI)
    func simulateUserSpeaking() {
        isUserSpeaking = true
        chatState = .userSpeaking
        
        // Detener después de 2 segundos
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            isUserSpeaking = false
            chatState = .listening
        }
    }
    
    // MARK: - Private Methods
    
    private func requestMicrophonePermission() async throws {
        // TODO: BACKEND - Implementar solicitud de permisos
        /*
        import AVFoundation
        
        let status = AVAudioSession.sharedInstance().recordPermission
        
        if status == .undetermined {
            let granted = await AVAudioSession.sharedInstance().requestRecordPermission()
            if !granted {
                throw VapiError.microphonePermissionDenied
            }
        } else if status == .denied {
            throw VapiError.microphonePermissionDenied
        }
        */
    }
    
    private func addMessage(text: String, isUser: Bool) {
        let message = ChatMessage(
            id: UUID(),
            text: text,
            isUser: isUser,
            timestamp: Date()
        )
        messages.append(message)
    }
    
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

// MARK: - TODO: Backend Implementation Notes

/*
 BACKEND PENDIENTE - Implementaciones necesarias:
 
 1. VapiClient.swift
    - Integración con Vapi SDK o API REST
    - Manejo de WebSocket para streaming de audio
    - Callbacks: onConnect, onDisconnect, onSpeechStart, onSpeechEnd, onTranscript, onError
    - Métodos: startSession(), endSession(), sendAudio()
 
 2. VapiConfig.swift
    - Configuración de llaves API
    - public static let publicKey = ProcessInfo.env("VAPI_PUBLIC_KEY")
    - public static let assistantId = ProcessInfo.env("VAPI_ASSISTANT_ID")
 
 3. AudioManager.swift
    - Captura de audio del micrófono
    - Detección de amplitud para waveform
    - Conversión de audio a formato requerido por Vapi
    - Manejo de AVAudioSession
 
 4. Permisos en Info.plist:
    - NSMicrophoneUsageDescription
    - Descripción: "Necesitamos acceso al micrófono para hablar con el chatbot"
 
 5. Instalación de SDK:
    - Agregar dependencia de Vapi iOS SDK
    - O implementar cliente REST/WebSocket personalizado
 
 6. Variables de entorno (.env):
    - VAPI_PUBLIC_KEY=tu_public_key
    - VAPI_ASSISTANT_ID=tu_assistant_id
 */
