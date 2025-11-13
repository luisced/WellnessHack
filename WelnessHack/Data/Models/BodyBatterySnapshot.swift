import Foundation

struct BodyBatterySnapshot: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let score: Int // 0-100
    
    // Component scores
    let sleepScore: Int
    let hrvScore: Int
    let activityScore: Int
    
    // Contributing factors
    let factors: [String]
    let recommendations: [String]
    
    // Metadata
    let sleepDuration: TimeInterval?
    let hrvAverage: Double?
    let activityLevel: String?
    
    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        score: Int,
        sleepScore: Int,
        hrvScore: Int,
        activityScore: Int,
        factors: [String] = [],
        recommendations: [String] = [],
        sleepDuration: TimeInterval? = nil,
        hrvAverage: Double? = nil,
        activityLevel: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.score = score
        self.sleepScore = sleepScore
        self.hrvScore = hrvScore
        self.activityScore = activityScore
        self.factors = factors
        self.recommendations = recommendations
        self.sleepDuration = sleepDuration
        self.hrvAverage = hrvAverage
        self.activityLevel = activityLevel
    }
    
    var scoreLevel: ScoreLevel {
        switch score {
        case 0..<25:
            return .critical
        case 25..<50:
            return .low
        case 50..<75:
            return .moderate
        case 75...100:
            return .high
        default:
            return .moderate
        }
    }
    
    var emoji: String {
        switch scoreLevel {
        case .critical:
            return "🔴"
        case .low:
            return "🟡"
        case .moderate:
            return "🟢"
        case .high:
            return "⚡"
        }
    }
}

enum ScoreLevel: String, Codable {
    case critical = "critical"
    case low = "low"
    case moderate = "moderate"
    case high = "high"
    
    var description: String {
        switch self {
        case .critical:
            return "Crítico - Necesitas descansar"
        case .low:
            return "Bajo - Evita esfuerzos intensos"
        case .moderate:
            return "Moderado - Energía estable"
        case .high:
            return "Alto - Excelente energía"
        }
    }
}

struct HealthMetrics: Codable {
    let sleepData: SleepMetrics?
    let hrvData: HRVMetrics?
    let activityData: ActivityMetrics?
    let timestamp: Date
    
    init(
        sleepData: SleepMetrics? = nil,
        hrvData: HRVMetrics? = nil,
        activityData: ActivityMetrics? = nil,
        timestamp: Date = Date()
    ) {
        self.sleepData = sleepData
        self.hrvData = hrvData
        self.activityData = activityData
        self.timestamp = timestamp
    }
}

struct SleepMetrics: Codable {
    let duration: TimeInterval
    let quality: Int // 0-100
    let deepSleepPercentage: Double
    let bedTime: Date?
    let wakeTime: Date?
}

struct HRVMetrics: Codable {
    let average: Double // milliseconds
    let baseline: Double? // user's typical HRV
    let trend: HRVTrend
}

enum HRVTrend: String, Codable {
    case improving = "improving"
    case stable = "stable"
    case declining = "declining"
}

struct ActivityMetrics: Codable {
    let steps: Int
    let activeCalories: Int
    let exerciseMinutes: Int
    let intensity: String // sedentary, light, moderate, high
    let restingHeartRate: Int?
}

