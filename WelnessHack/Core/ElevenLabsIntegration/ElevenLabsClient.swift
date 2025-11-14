import Foundation
import ElevenLabs
import Combine

@MainActor
class ElevenLabsClient: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var isConnected = false
    @Published var isMuted = false
    @Published var agentState: AgentState = .listening
    @Published var connectionStatus = "Disconnected"
    @Published var messages: [Message] = []
    @Published var conversationHistory: [ConversationMessage] = []
    
    // MARK: - Private Properties
    
    private var conversation: Conversation?
    private var cancellables = Set<AnyCancellable>()
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
        
        // Configure conversation
        let config = ConversationConfig(
            conversationOverrides: ConversationOverrides(
                textOnly: false // Enable voice
            )
        )
        
        // Start conversation with ElevenLabs
        conversation = try await ElevenLabs.startConversation(
            agentId: ElevenLabsConfig.agentID,
            userId: context.conversationID,
            config: config
        )
        
        setupObservers()
        setupClientTools()
        
        print("✅ Connected to ElevenLabs Agent")
        print("Agent ID: \(ElevenLabsConfig.agentID)")
        print("Context: \(context.agentDescription)")
    }
    
    func endConversation() async {
        await conversation?.endConversation()
        conversation = nil
        cancellables.removeAll()
        isConnected = false
        connectionStatus = "Disconnected"
        print("🔌 Disconnected from ElevenLabs")
    }
    
    // MARK: - Observers Setup
    
    private func setupObservers() {
        guard let conversation = conversation else { return }
        
        // Monitor messages
        conversation.$messages
            .sink { [weak self] messages in
                self?.messages = messages
                self?.updateConversationHistory(from: messages)
            }
            .store(in: &cancellables)
        
        // Monitor connection state
        conversation.$state
            .sink { [weak self] state in
                self?.handleStateChange(state)
            }
            .store(in: &cancellables)
        
        // Monitor agent state (speaking/listening)
        conversation.$agentState
            .assign(to: &$agentState)
        
        // Monitor mute state
        conversation.$isMuted
            .assign(to: &$isMuted)
    }
    
    private func handleStateChange(_ state: ConversationState) {
        switch state {
        case .idle:
            connectionStatus = "Disconnected"
            isConnected = false
        case .connecting:
            connectionStatus = "Connecting..."
            isConnected = false
        case .active(let callInfo):
            connectionStatus = "Connected"
            isConnected = true
            print("📞 Call active with agent: \(callInfo.agentId)")
        case .ended(let reason):
            connectionStatus = "Ended: \(reason)"
            isConnected = false
            print("📴 Call ended: \(reason)")
        case .error(let error):
            connectionStatus = "Error"
            isConnected = false
            print("❌ Error: \(error)")
        }
    }
    
    private func updateConversationHistory(from messages: [Message]) {
        conversationHistory = messages.map { message in
            ConversationMessage(
                role: message.role == .user ? .user : .assistant,
                content: message.content,
                timestamp: Date()
            )
        }
    }
    
    // MARK: - Audio Controls
    
    func toggleMute() async throws {
        try await conversation?.toggleMute()
    }
    
    func setMuted(_ muted: Bool) async throws {
        try await conversation?.setMuted(muted)
    }
    
    // MARK: - Message Handling
    
    func sendMessage(_ text: String) async throws {
        guard isConnected else {
            throw ElevenLabsError.connectionFailed
        }
        
        try await conversation?.sendMessage(text)
        print("💬 Sent message: \(text)")
    }
    
    // MARK: - Client Tools Setup
    
    private func setupClientTools() {
        guard let conversation = conversation else { return }
        
        // Listen for client tool calls from the agent
        conversation.$clientToolCalls
            .sink { [weak self] toolCalls in
                for toolCall in toolCalls {
                    Task {
                        await self?.handleToolCall(toolCall)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func handleToolCall(_ toolCall: ClientToolCallEvent) async {
        print("🔧 Tool called: \(toolCall.toolName)")
        
        do {
            let parameters = try toolCall.getParameters()
            let result = await executeClientTool(
                name: toolCall.toolName,
                parameters: parameters
            )
            
            if toolCall.expectsResponse {
                try await conversation?.sendToolResult(
                    for: toolCall.toolCallId,
                    result: result
                )
                print("✅ Tool result sent for: \(toolCall.toolName)")
            } else {
                conversation?.markToolCallCompleted(toolCall.toolCallId)
                print("✅ Tool completed: \(toolCall.toolName)")
            }
        } catch {
            print("❌ Tool execution failed: \(error)")
            if toolCall.expectsResponse {
                try? await conversation?.sendToolResult(
                    for: toolCall.toolCallId,
                    result: ["error": error.localizedDescription],
                    isError: true
                )
            }
        }
    }
    
    private func executeClientTool(name: String, parameters: [String: Any]) async -> [String: Any] {
        guard let toolHandler = toolHandler else {
            return ["error": "Tool handler not initialized"]
        }
        
        do {
            switch name {
            case "get_current_energy_score":
                return try await toolHandler.getCurrentEnergyScore()
                
            case "get_energy_forecast":
                let hours = parameters["hours"] as? Int ?? 6
                return try await toolHandler.getEnergyForecast(hours: hours)
                
            case "get_sleep_analysis":
                return try await toolHandler.getSleepAnalysis()
                
            case "get_activity_summary":
                return try await toolHandler.getActivitySummary()
                
            case "recommend_actions":
                let context = parameters["context"] as? String ?? ""
                return try await toolHandler.recommendActions(context: context)
                
            default:
                return ["error": "Unknown tool: \(name)"]
            }
        } catch {
            return ["error": error.localizedDescription]
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

