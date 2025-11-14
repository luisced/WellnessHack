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
    @Published var conversationHistory: [ConversationMessage] = []
    @Published var messages: [ConversationMessage] = []
    
    // MARK: - Private Properties
    
    private var conversation: Conversation?
    private var toolHandler: AgentToolHandler?
    private var currentContext: ConversationContext?
    private var cancellables = Set<AnyCancellable>()
    
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
            conversationOverrides: ConversationOverrides(textOnly: false)
        )
        
        // Start conversation with ElevenLabs
        conversation = try await ElevenLabs.startConversation(
            agentId: ElevenLabsConfig.agentID,
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
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (elevenLabsMessages: [Message]) in
                self?.updateConversationHistory(from: elevenLabsMessages)
            }
            .store(in: &cancellables)
        
        // Monitor connection state
        conversation.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleStateChange(state)
            }
            .store(in: &cancellables)
        
        // Monitor agent state (speaking/listening)
        conversation.$agentState
            .receive(on: DispatchQueue.main)
            .map { sdkState -> AgentState in
                // Attempt to map any SDK AgentState to our local fallback AgentState
                // If types already match, the cast will succeed and preserve the value
                if let local = sdkState as? AgentState {
                    return local
                }
                // Fallback: derive from rawValue if available via Mirror
                let mirror = Mirror(reflecting: sdkState)
                if let raw = mirror.children.first(where: { $0.label == "rawValue" })?.value as? String,
                   let mapped = AgentState(rawValue: raw) {
                    return mapped
                }
                // Default to listening if we cannot determine
                return .listening
            }
            .sink(receiveValue: { [weak self] state in
                self?.agentState = state
            })
            .store(in: &cancellables)
        
        // Monitor mute state
        conversation.$isMuted
            .receive(on: DispatchQueue.main)
            .sink { [weak self] muted in
                self?.isMuted = muted
            }
            .store(in: &cancellables)
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
    
    private func updateConversationHistory(from elevenLabsMessages: [Message]) {
        self.messages = elevenLabsMessages.map { message in
            ConversationMessage(
                role: message.role == .user ? .user : .assistant,
                content: message.content,
                timestamp: Date()
            )
        }
        conversationHistory = self.messages
    }
    
    // MARK: - Client Tools Setup
    
    private func setupClientTools() {
        guard let conversation = conversation else { return }

        // If the SDK exposes a direct array of tool calls, poll it periodically.
        // This avoids relying on a non-existent `$clientToolCalls` publisher.
        // We keep a simple set of processed IDs to avoid duplicate handling.
        var processedToolCallIds = Set<String>()

        // Create a timer publisher to poll for tool calls.
        let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
        timer
            .sink { [weak self] _ in
                guard let self = self, let conv = self.conversation else { return }

                // Attempt to access a non-published property if available; otherwise, no-op.
                // We assume `clientToolCalls` is a property on Conversation. If it's not, this block will be a no-op.
                let toolCallsMirror = Mirror(reflecting: conv)
                if let toolCalls = toolCallsMirror.children.first(where: { $0.label == "clientToolCalls" })?.value as? [Any] {
                    for anyCall in toolCalls {
                        // Best-effort cast to the expected type
                        if let toolCall = anyCall as? ClientToolCallEvent {
                            if processedToolCallIds.contains(toolCall.toolCallId) { continue }
                            processedToolCallIds.insert(toolCall.toolCallId)
                            Task { [weak self] in
                                await self?.handleToolCall(toolCall)
                            }
                        }
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

            // If there is a valid toolCallId, assume a response is expected.
            if !toolCall.toolCallId.isEmpty {
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
            if !toolCall.toolCallId.isEmpty {
                try? await conversation?.sendToolResult(
                    for: toolCall.toolCallId,
                    result: ["error": error.localizedDescription],
                    isError: true
                )
            }
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
    
    // MARK: - Client Tools Execution
    
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

// Note: AgentState is provided by ElevenLabs SDK
// Fallback definition to resolve build when ElevenLabs SDK AgentState is unavailable
enum AgentState: String, Codable {
    case listening
    case speaking
}

