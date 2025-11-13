# Vapi Integration Guide

## Overview

Vapi is the conversational AI platform powering the Life Coach experience. Instead of direct LLM integration, all natural language interactions flow through Vapi for enhanced features like voice, session management, and conversation context.

## Core Concepts

### Vapi Assistant
A configured Vapi instance that handles:
- Voice call routing and DTMF support
- Message routing (text/voice)
- Call recording and transcription
- Session state management
- Integration with external tools and webhooks

### Session
A conversation session between the user and Vapi. Sessions:
- Persist across app restarts (stored in Data layer)
- Include full transcripts and metadata
- Carry context (body battery, goals, calendar, emotions detected)
- Can be resumed or continued

### Message Types
- **User Message**: User input (voice transcribed or text typed)
- **Assistant Message**: Vapi response (generated and spoken/displayed)
- **Action Message**: Triggered actions (set reminder, change focus mode, etc.)
- **System Message**: Context updates (body battery changed, new event, etc.)

## Architecture

```
┌────────────────┐
│  SwiftUI View  │
└────────┬───────┘
         │
         ▼
┌────────────────────────┐
│  VapiIntegration       │
│  - Session management  │
│  - Call initiation     │
│  - Message routing     │
└────────┬───────────────┘
         │
         ▼
┌────────────────────────┐
│  Vapi API              │
│  - REST/WebSocket      │
│  - Authentication      │
│  - Audio streaming     │
└────────┬───────────────┘
         │
         ▼
┌────────────────────────┐
│  Vapi Backend          │
│  - LLM processing      │
│  - Voice synthesis     │
│  - Tool execution      │
└────────────────────────┘
```

## Setup & Configuration

### Prerequisites
1. Vapi account with assistant configured
2. API key (stored securely in Keychain)
3. Assistant ID from Vapi dashboard

### Configuration File
Create `VapiConfig.swift`:
```swift
struct VapiConfig {
    static let apiKey = "your-api-key-here"
    static let assistantId = "your-assistant-id"
    static let baseURL = URL(string: "https://api.vapi.ai")!
    static let enableTranscription = true
    static let enableRecording = true
}
```

### Permissions Required
- Microphone (for voice input)
- Camera (for food photos, optional for video)
- Contacts (for calendar integration)
- Health (HealthKit access)

## Implementation Patterns

### Initiating a Call

```swift
let session = VapiSession()
let context: [String: Any] = [
    "bodyBattery": 72,
    "currentMood": "tired",
    "nextEvent": "meeting at 3pm"
]
try await vapiClient.startCall(
    assistantId: VapiConfig.assistantId,
    context: context,
    session: session
)
```

### Handling Messages

```swift
func handleMessage(_ message: VapiMessage) {
    switch message.type {
    case .userMessage:
        // Store in conversation repository
        repository.save(message)
    case .assistantMessage:
        // Update UI with response
        updateChatUI(message.content)
    case .action:
        // Trigger recommended action
        executeAction(message.action)
    case .system:
        // Update context (e.g., mood changed)
        updateContext(message.metadata)
    }
}
```

### Managing Sessions

```swift
// Retrieve session history
let session = try await repository.getSession(by: sessionId)
let messages = session.messages

// Resume a previous conversation
try await vapiClient.resumeCall(sessionId: sessionId)

// End and save session
try await vapiClient.endCall()
await repository.save(session)
```

## Tool Integration

Vapi can trigger external tools to:
- Set reminders or calendar events
- Control focus modes
- Log meals
- Update goals
- Retrieve body battery scores

### Tool Definition Format

```json
{
  "name": "set_reminder",
  "description": "Create a reminder for the user",
  "parameters": {
    "title": "string",
    "timeMinutes": "number",
    "type": "enum(meditation|break|water|movement)"
  }
}
```

### Handling Tool Execution

```swift
func handleToolExecution(_ tool: VapiTool) {
    switch tool.name {
    case "set_reminder":
        let title = tool.parameters["title"] as? String ?? ""
        let minutes = tool.parameters["timeMinutes"] as? Int ?? 0
        NotificationScheduler.schedule(title: title, minutesFromNow: minutes)
        
    case "update_focus_mode":
        let mode = tool.parameters["mode"] as? String ?? "light"
        ScreenTimeManager.setFocusMode(mode)
        
    case "log_meal":
        let meal = tool.parameters["meal"] as? String ?? ""
        MealRepository.add(meal)
        
    default:
        break
    }
}
```

## Error Handling

### Common Errors

| Error | Cause | Recovery |
|-------|-------|----------|
| `CallInitiationFailed` | Network or auth issue | Retry with exponential backoff |
| `NoMicrophonePermission` | User denied permission | Prompt to enable in settings |
| `SessionTimeout` | Vapi session expired | Create new session |
| `AudioPlaybackError` | Speaker issue | Fall back to text display |

### Implementation

```swift
do {
    try await vapiClient.startCall(assistantId: assistantId, context: context)
} catch VapiError.noMicrophonePermission {
    // Show settings prompt
    showPermissionAlert()
} catch VapiError.networkError {
    // Retry or show offline message
    retryWithBackoff()
} catch {
    // Generic error handling
    logError(error)
}
```

## Context Passing

### Available Context Variables

```swift
struct VapiContext {
    var bodyBattery: Int                  // 0-100 energy score
    var currentMood: String               // detected emotion
    var nextEvent: String                 // upcoming calendar event
    var daysFocusMaintained: Int         // streak counter
    var hasMeditatedToday: Bool          // habit check
    var lastMealTime: Date?              // nutrition context
    var focusModeActive: Bool            // work boundary
    var userGoals: [String]              // goal list
    var weeklyTrends: [String: Double]   // analytics
}
```

### Passing Context During Calls

```swift
let context = VapiContext(
    bodyBattery: bodyBatteryEngine.currentScore,
    currentMood: conversationAnalyzer.detectMood(lastMessage),
    nextEvent: calendarService.upcomingEvent?.title ?? "none",
    daysFocusMaintained: habitTracker.focusStreak,
    ...
)

try await vapiClient.updateContext(context)
```

## Conversation Lifecycle

1. **Initiation** - User taps voice button
2. **Connection** - Vapi establishes WebSocket
3. **Greeting** - Vapi delivers opening message
4. **Dialogue** - User and Vapi exchange messages
5. **Action Triggers** - User requests actions or Vapi recommends them
6. **Closure** - User ends call or timeout
7. **Storage** - Session and transcript saved
8. **Analysis** - Emotion detection, pattern analysis, feedback generation

## Compliance & Privacy

### Data Handling
- **Transcripts**: Encrypted and stored locally; never shared without permission
- **Audio Recordings**: Optional; encrypted; deleted after transcription
- **Session Context**: Non-PII context (battery level, mood) only
- **Deletion**: User can delete full session history at any time

### Consent
- Display consent banner before first call
- Allow opt-out of recording/transcription
- Honor privacy preferences across features

## Testing with Vapi

### Mock Vapi Responses

```swift
class MockVapiClient: VapiClientProtocol {
    var mockMessages: [VapiMessage] = []
    
    func startCall(...) async throws {
        // Return mock messages
        for message in mockMessages {
            handleMessage(message)
        }
    }
}
```

### Test Scenarios
- Happy path: full conversation with action triggers
- Error handling: network failures, timeout, permissions
- Context updates: body battery changes mid-call
- Tool execution: successful and failed action outcomes

## Monitoring & Analytics

### Metrics to Track
- Call duration and frequency
- Message count per session
- Tool execution success rate
- Error rates by type
- User sentiment trends
- Feature adoption per slice

### Implementation

```swift
func trackVapiEvent(_ eventName: String, metadata: [String: Any]) {
    AnalyticsService.log(
        eventName: eventName,
        metadata: metadata.merging([
            "platform": "vapi",
            "timestamp": Date()
        ]) { _, new in new }
    )
}
```

## Resources

- [Vapi Documentation](https://docs.vapi.ai)
- [Vapi API Reference](https://docs.vapi.ai/api-reference)
- [Vapi Dashboard](https://dashboard.vapi.ai)

