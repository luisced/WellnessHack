import Foundation
import ElevenLabsSDK
import Combine

@MainActor
class ElevenLabsClient: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var isConnected = false
    @Published var isMuted = false
    @Published var agentState: AgentState = .listening
    @Published var connectionStatus = "Disconnected"
    @Published var conversationHistory: [ConversationMessage] = []
    @Published var messages: [ConversationMessage] = []
    
    // MARK: - Private Properties
    
    private var conversation: ElevenLabsSDK.Conversation?
    private var toolHandler: AgentToolHandler?
    private var currentContext: ConversationContext?
    
    // MARK: - Initialization
    
    init() {
        toolHandler = AgentToolHandler()
    }
    
    // MARK: - Connection Management
    
    func startConversation(with context: ConversationContext) async throws {
        try ElevenLabsConfig.validate()
        
        currentContext = context
        
        // Configure session
        let config = ElevenLabsSDK.SessionConfig(agentId: ElevenLabsConfig.agentID)
        
        // Setup callbacks
        var callbacks = ElevenLabsSDK.Callbacks()
        
        callbacks.onConnect = { [weak self] conversationId in
            Task { @MainActor in
                self?.isConnected = true
                self?.connectionStatus = "Connected"
                print("✅ Connected with ID: \(conversationId)")
            }
        }
        
        callbacks.onDisconnect = { [weak self] in
            Task { @MainActor in
                self?.isConnected = false
                self?.connectionStatus = "Disconnected"
                print("🔌 Disconnected from ElevenLabs")
            }
        }
        
        callbacks.onMessage = { [weak self] message, role in
            Task { @MainActor in
                let msg = ConversationMessage(
                    role: role == .user ? .user : .assistant,
                    content: message,
                    timestamp: Date()
                )
                self?.conversationHistory.append(msg)
                self?.messages.append(msg)
                print("💬 \(role.rawValue): \(message)")
            }
        }
        
        callbacks.onError = { [weak self] error, info in
            Task { @MainActor in
                self?.connectionStatus = "Error"
                print("❌ Error: \(error), Info: \(String(describing: info))")
            }
        }
        
        callbacks.onStatusChange = { [weak self] status in
            Task { @MainActor in
                switch status {
                case .connected:
                    self?.isConnected = true
                    self?.connectionStatus = "Connected"
                case .connecting:
                    self?.connectionStatus = "Connecting..."
                case .disconnected:
                    self?.isConnected = false
                    self?.connectionStatus = "Disconnected"
                @unknown default:
                    break
                }
                print("📊 Status: \(status.rawValue)")
            }
        }
        
        callbacks.onModeChange = { mode in
            print("🔄 Mode changed to: \(mode.rawValue)")
        }
        
        // Setup client tools
        var clientTools = ElevenLabsSDK.ClientTools()
        
        clientTools.register("get_current_energy_score") { [weak self] parameters in
            try await self?.executeClientTool(name: "get_current_energy_score", parameters: parameters ?? [:])
        }
        
        clientTools.register("get_energy_forecast") { [weak self] parameters in
            try await self?.executeClientTool(name: "get_energy_forecast", parameters: parameters ?? [:])
        }
        
        clientTools.register("get_sleep_analysis") { [weak self] parameters in
            try await self?.executeClientTool(name: "get_sleep_analysis", parameters: parameters ?? [:])
        }
        
        clientTools.register("get_activity_summary") { [weak self] parameters in
            try await self?.executeClientTool(name: "get_activity_summary", parameters: parameters ?? [:])
        }
        
        clientTools.register("recommend_actions") { [weak self] parameters in
            try await self?.executeClientTool(name: "recommend_actions", parameters: parameters ?? [:])
        }
        
        // Start conversation
        conversation = try await ElevenLabsSDK.Conversation.startSession(
            config: config,
            callbacks: callbacks,
            clientTools: clientTools
        )
        
        print("✅ Connected to ElevenLabs Agent")
        print("Agent ID: \(ElevenLabsConfig.agentID)")
        print("Context: \(context.agentDescription)")
    }
    
    func endConversation() async {
        conversation?.endSession()
        conversation = nil
        isConnected = false
        connectionStatus = "Disconnected"
        print("🔌 Session ended")
    }
    
    // MARK: - Audio Controls
    
    func toggleMute() async throws {
        if isMuted {
            conversation?.startRecording()
        } else {
            conversation?.stopRecording()
        }
        isMuted.toggle()
    }
    
    func setMuted(_ muted: Bool) async throws {
        if muted {
            conversation?.stopRecording()
        } else {
            conversation?.startRecording()
        }
        isMuted = muted
    }
    
    // MARK: - Message Handling
    
    func sendMessage(_ text: String) async throws {
        // Note: v1.2.3 is voice-only, but we add the message to history for UI consistency
        let msg = ConversationMessage(
            role: .user,
            content: text,
            timestamp: Date()
        )
        conversationHistory.append(msg)
        messages.append(msg)
        print("💬 Message added to history (voice-only mode): \(text)")
    }
    
    // MARK: - Client Tools Execution
    
    private func executeClientTool(name: String, parameters: [String: Any]) async throws -> String? {
        guard let toolHandler = toolHandler else {
            return "{\"error\": \"Tool handler not initialized\"}"
        }
        
        do {
            let result: [String: Any]
            
            switch name {
            case "get_current_energy_score":
                result = try await toolHandler.getCurrentEnergyScore()
                
            case "get_energy_forecast":
                let hours = parameters["hours"] as? Int ?? 6
                result = try await toolHandler.getEnergyForecast(hours: hours)
                
            case "get_sleep_analysis":
                result = try await toolHandler.getSleepAnalysis()
                
            case "get_activity_summary":
                result = try await toolHandler.getActivitySummary()
                
            case "recommend_actions":
                let context = parameters["context"] as? String ?? ""
                result = try await toolHandler.recommendActions(context: context)
                
            default:
                result = ["error": "Unknown tool: \(name)"]
            }
            
            // Convert to JSON string
            if let jsonData = try? JSONSerialization.data(withJSONObject: result),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                print("✅ Tool result for \(name): \(jsonString)")
                return jsonString
            }
            
            return nil
        } catch {
            let errorResult = ["error": error.localizedDescription]
            if let jsonData = try? JSONSerialization.data(withJSONObject: errorResult),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
            return nil
        }
    }
}

// MARK: - Supporting Models

struct ConversationMessage: Identifiable, Codable {
    let id = UUID()
    let role: MessageRole
    let content: String
    let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case role, content, timestamp
    }
}

enum MessageRole: String, Codable {
    case user = "user"
    case assistant = "assistant"
    case system = "system"
}

// Agent state for UI
enum AgentState {
    case listening
    case speaking
    case thinking
    case idle
}

// Type alias for compatibility
typealias Message = ConversationMessage
