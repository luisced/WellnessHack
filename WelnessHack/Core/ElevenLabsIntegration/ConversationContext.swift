import Foundation

struct ConversationContext: Codable {
    // User state
    let bodyBattery: Int
    let energyLevel: String
    
    // Health metrics
    let sleepLastNight: String
    let sleepQuality: Int
    let hrvAverage: Double?
    let activityToday: String
    
    // Temporal context
    let timeOfDay: String
    let dayOfWeek: String
    let currentTime: Date
    
    // User preferences
    let language: String
    let userName: String?
    
    // Conversation state
    let conversationID: String
    let messageCount: Int
    let lastInteraction: Date?
    
    init(
        bodyBattery: Int,
        energyLevel: String,
        sleepLastNight: String,
        sleepQuality: Int,
        hrvAverage: Double? = nil,
        activityToday: String,
        timeOfDay: String,
        dayOfWeek: String,
        currentTime: Date = Date(),
        language: String = "es",
        userName: String? = nil,
        conversationID: String = UUID().uuidString,
        messageCount: Int = 0,
        lastInteraction: Date? = nil
    ) {
        self.bodyBattery = bodyBattery
        self.energyLevel = energyLevel
        self.sleepLastNight = sleepLastNight
        self.sleepQuality = sleepQuality
        self.hrvAverage = hrvAverage
        self.activityToday = activityToday
        self.timeOfDay = timeOfDay
        self.dayOfWeek = dayOfWeek
        self.currentTime = currentTime
        self.language = language
        self.userName = userName
        self.conversationID = conversationID
        self.messageCount = messageCount
        self.lastInteraction = lastInteraction
    }
    
    // MARK: - Factory Methods
    
    /// Crea un contexto para onboarding (primera vez del usuario)
    static func createForOnboarding() -> ConversationContext {
        let calendar = Calendar.current
        let now = Date()
        
        // Determine time of day
        let hour = calendar.component(.hour, from: now)
        let timeOfDay: String
        switch hour {
        case 5..<12:
            timeOfDay = "morning"
        case 12..<17:
            timeOfDay = "afternoon"
        case 17..<21:
            timeOfDay = "evening"
        default:
            timeOfDay = "night"
        }
        
        // Day of week
        let weekday = calendar.component(.weekday, from: now)
        let dayOfWeek = calendar.weekdaySymbols[weekday - 1]
        
        return ConversationContext(
            bodyBattery: 50, // Default neutral value
            energyLevel: "unknown",
            sleepLastNight: "unknown",
            sleepQuality: 0,
            hrvAverage: nil,
            activityToday: "unknown",
            timeOfDay: timeOfDay,
            dayOfWeek: dayOfWeek,
            currentTime: now,
            language: "es",
            userName: nil,
            conversationID: "onboarding_\(UUID().uuidString)",
            messageCount: 0,
            lastInteraction: nil
        )
    }
    
    static func create(from snapshot: BodyBatterySnapshot, sleepData: SleepData?, activityData: ActivityData?) async -> ConversationContext {
        let calendar = Calendar.current
        let now = Date()
        
        // Determine time of day
        let hour = calendar.component(.hour, from: now)
        let timeOfDay: String
        switch hour {
        case 5..<12:
            timeOfDay = "morning"
        case 12..<17:
            timeOfDay = "afternoon"
        case 17..<21:
            timeOfDay = "evening"
        default:
            timeOfDay = "night"
        }
        
        // Day of week
        let weekday = calendar.component(.weekday, from: now)
        let dayOfWeek = calendar.weekdaySymbols[weekday - 1]
        
        // Sleep summary
        let sleepSummary: String
        if let sleep = sleepData {
            let hours = Int(sleep.durationHours)
            let minutes = Int((sleep.durationHours - Double(hours)) * 60)
            sleepSummary = "\(hours)h \(minutes)m"
        } else {
            sleepSummary = "No data"
        }
        
        // Activity summary
        let activitySummary = activityData?.intensity.rawValue ?? "unknown"
        
        return ConversationContext(
            bodyBattery: snapshot.score,
            energyLevel: snapshot.scoreLevel.rawValue,
            sleepLastNight: sleepSummary,
            sleepQuality: sleepData?.quality ?? 0,
            hrvAverage: snapshot.hrvAverage,
            activityToday: activitySummary,
            timeOfDay: timeOfDay,
            dayOfWeek: dayOfWeek,
            currentTime: now
        )
    }
    
    // MARK: - Context Updates
    
    func withUpdatedMessageCount() -> ConversationContext {
        return ConversationContext(
            bodyBattery: bodyBattery,
            energyLevel: energyLevel,
            sleepLastNight: sleepLastNight,
            sleepQuality: sleepQuality,
            hrvAverage: hrvAverage,
            activityToday: activityToday,
            timeOfDay: timeOfDay,
            dayOfWeek: dayOfWeek,
            currentTime: currentTime,
            language: language,
            userName: userName,
            conversationID: conversationID,
            messageCount: messageCount + 1,
            lastInteraction: Date()
        )
    }
    
    func withUpdatedBodyBattery(_ newScore: Int, _ newLevel: String) -> ConversationContext {
        return ConversationContext(
            bodyBattery: newScore,
            energyLevel: newLevel,
            sleepLastNight: sleepLastNight,
            sleepQuality: sleepQuality,
            hrvAverage: hrvAverage,
            activityToday: activityToday,
            timeOfDay: timeOfDay,
            dayOfWeek: dayOfWeek,
            currentTime: currentTime,
            language: language,
            userName: userName,
            conversationID: conversationID,
            messageCount: messageCount,
            lastInteraction: lastInteraction
        )
    }
    
    // MARK: - JSON Representation
    
    func toJSON() -> [String: Any] {
        return [
            "body_battery": bodyBattery,
            "energy_level": energyLevel,
            "sleep_last_night": sleepLastNight,
            "sleep_quality": sleepQuality,
            "hrv_average": hrvAverage ?? 0,
            "activity_today": activityToday,
            "time_of_day": timeOfDay,
            "day_of_week": dayOfWeek,
            "current_time": ISO8601DateFormatter().string(from: currentTime),
            "language": language,
            "user_name": userName ?? "User",
            "conversation_id": conversationID,
            "message_count": messageCount
        ]
    }
    
    // MARK: - Description for Agent
    
    var agentDescription: String {
        """
        Current State:
        - Energy: \(bodyBattery)/100 (\(energyLevel))
        - Sleep: \(sleepLastNight) (quality: \(sleepQuality)/100)
        - HRV: \(hrvAverage.map { String(format: "%.1f", $0) } ?? "N/A") ms
        - Activity: \(activityToday)
        - Time: \(timeOfDay), \(dayOfWeek)
        - Messages: \(messageCount)
        """
    }
}

