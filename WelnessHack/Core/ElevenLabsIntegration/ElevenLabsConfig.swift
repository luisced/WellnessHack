import Foundation

struct ElevenLabsConfig {
    // MARK: - API Configuration
    
    static var apiKey: String {
        EnvLoader.get("ELEVENLABS_API_KEY") ?? ""
    }
    
    static var agentID: String {
        EnvLoader.get("ELEVENLABS_AGENT_ID") ?? ""
    }
    
    // API Endpoints
    static let websocketURL = "wss://api.elevenlabs.io/v1/convai/conversation"
    static let baseURL = "https://api.elevenlabs.io/v1"
    
    // MARK: - Agent Settings
    
    struct AgentSettings {
        let language: String
        let voiceID: String?
        let enableTranscription: Bool
        let enableRecording: Bool
        
        static let `default` = AgentSettings(
            language: "es", // Spanish
            voiceID: nil, // Use agent's default voice
            enableTranscription: true,
            enableRecording: false
        )
    }
    
    // MARK: - Validation
    
    static func isConfigured() -> Bool {
        return !apiKey.isEmpty && !agentID.isEmpty
    }
    
    static func validate() throws {
        guard !apiKey.isEmpty else {
            throw ElevenLabsError.missingAPIKey
        }
        
        guard !agentID.isEmpty else {
            throw ElevenLabsError.missingAgentID
        }
    }
}

// MARK: - Errors

enum ElevenLabsError: Error, LocalizedError {
    case missingAPIKey
    case missingAgentID
    case connectionFailed
    case authenticationFailed
    case invalidResponse
    case toolExecutionFailed(String)
    case audioProcessingFailed
    
    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "ElevenLabs API key is missing. Set ELEVENLABS_API_KEY environment variable."
        case .missingAgentID:
            return "ElevenLabs Agent ID is missing. Set ELEVENLABS_AGENT_ID environment variable."
        case .connectionFailed:
            return "Failed to connect to ElevenLabs service"
        case .authenticationFailed:
            return "Authentication with ElevenLabs failed"
        case .invalidResponse:
            return "Received invalid response from ElevenLabs"
        case .toolExecutionFailed(let tool):
            return "Failed to execute tool: \(tool)"
        case .audioProcessingFailed:
            return "Failed to process audio"
        }
    }
}

