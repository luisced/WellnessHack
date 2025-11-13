# Data Models Specification

## Core Models

### User

```swift
struct User {
    let id: UUID
    let name: String
    let email: String?
    
    // Profile
    let birthDate: Date?
    let gender: String?
    
    // Preferences
    let goals: [Goal]
    let persona: String?  // Theater mental narrative
    let preferredCoachingStyle: String?
    
    // Settings
    let notificationsEnabled: Bool
    let recordingEnabled: Bool
    let sharingEnabled: Bool
    let privacyLevel: PrivacyLevel  // low, medium, high
    
    // Timestamps
    let createdAt: Date
    let updatedAt: Date
    let lastActiveAt: Date?
}

enum PrivacyLevel: String {
    case low      // All data collection enabled
    case medium   // Essential data only
    case high     // Minimal data collection
}
```

### Goal

```swift
struct Goal {
    let id: UUID
    let userId: UUID
    let title: String
    let description: String
    
    // Types: burnout-prevention, discipline, nutrition, time-management, mental-health
    let type: String
    
    // Progress
    let startDate: Date
    let targetDate: Date?
    var progressPercentage: Double  // 0-100
    
    // Status: active, paused, completed, abandoned
    let status: String
    
    // Metrics tracked for this goal
    let keyMetrics: [String]  // e.g., ["body_battery", "workout_minutes"]
    
    let createdAt: Date
    let updatedAt: Date
}
```

### BodyBattery

```swift
struct BodyBatterySnapshot {
    let id: UUID
    let userId: UUID
    
    // Score 0-100
    let score: Int
    
    // Components
    let sleepScore: Int?      // 0-100, from HealthKit
    let hrvScore: Int?        // 0-100, normalized from HRV data
    let activityScore: Int?   // 0-100, from activity intensity
    
    // Factors contributing to score
    let factors: [String]  // e.g., ["low_sleep", "high_stress", "good_exercise"]
    
    // Recommendations based on score
    let recommendations: [String]
    
    // Metadata
    let timestamp: Date
    let timezone: String
}

// Historical aggregates
struct BodyBatteryDaily {
    let userId: UUID
    let date: Date
    
    let minScore: Int
    let maxScore: Int
    let avgScore: Int
    let scoreAtMorning: Int
    let scoreAtEvening: Int
    
    let peakHour: Int?  // Hour of day with highest score
    let lowestHour: Int?  // Hour of day with lowest score
    
    let sleepDuration: TimeInterval?
    let sleepQuality: Int?
    
    let stressEvents: Int  // Count of detected stress spikes
    let recoveryEvents: Int  // Count of detected recovery moments
}

struct BodyBatteryWeekly {
    let userId: UUID
    let weekStartDate: Date
    
    let avgScore: Int
    let consistency: Double  // 0-100, how stable score was
    let trend: String  // "increasing", "decreasing", "stable"
    
    let bestDay: Date?
    let worstDay: Date?
}
```

### DailyMetrics

```swift
struct DailyMetrics {
    let id: UUID
    let userId: UUID
    let date: Date
    
    // Energy
    let bodyBatteryMin: Int
    let bodyBatteryMax: Int
    let bodyBatteryAvg: Int
    
    // Sleep (from previous night)
    let sleepDuration: TimeInterval
    let sleepQuality: Int?  // 0-100
    let sleepDeepPercentage: Double?  // % of deep sleep
    
    // Activity
    let stepsCount: Int?
    let caloriesBurned: Int?
    let workoutMinutes: Int?
    let workoutIntensity: String?  // light, moderate, high
    
    // Nutrition
    let mealCount: Int
    let macroBalance: [String: Double]?  // {"protein": 30, "carbs": 45, "fat": 25}
    
    // Habits
    let habitsCompleted: Int
    let habitsAttempted: Int
    
    // Emotional
    let predominantMood: String?  // happy, neutral, stressed, sad, anxious
    let moodVariation: Double?  // how much mood changed throughout day
    
    // Focus
    let focusModeMinutes: Int
    let distractionCount: Int  // app checks during focus time
    
    // Summary
    let noteFromVapi: String?  // Coach's generated note
    
    let createdAt: Date
}
```

### Meal

```swift
struct Meal {
    let id: UUID
    let userId: UUID
    
    let photoURL: URL?
    let photoData: Data?  // For local storage before upload
    
    // Inferred composition
    let name: String?
    let ingredients: [String]?
    let estimatedWeight: Double?  // in grams
    
    // Nutrition facts (per serving)
    let calories: Int?
    let protein: Double?  // grams
    let carbs: Double?    // grams
    let fat: Double?      // grams
    let fiber: Double?    // grams
    let sodium: Int?      // mg
    
    // Micronutrients
    let vitamins: [String: String]?  // e.g., {"vitamin_c": "high", "iron": "medium"}
    let minerals: [String: String]?
    
    // Health benefits
    let benefits: [String]  // e.g., ["sustained_energy", "muscle_recovery", "digestion"]
    let healthScore: Int?  // 0-100, overall healthiness
    
    // Energy stability
    let energyStabilityDuration: Int?  // minutes the meal will maintain stable energy
    let energyPeak: Int?  // minutes until peak energy post-meal
    
    // User notes
    let userNotes: String?
    
    // Timing
    let mealType: String  // breakfast, lunch, dinner, snack
    let timestamp: Date
    
    // Classification
    let category: String?  // homemade, restaurant, packaged, processed
    let isHealthy: Bool?
}
```

### Conversation

```swift
struct Conversation {
    let id: UUID
    let userId: UUID
    
    let messages: [Message]
    let startTime: Date
    let endTime: Date?
    
    // Vapi session
    let vapiSessionId: String?
    let vapiCallId: String?
    
    // Metadata
    let topic: String?  // e.g., "energy", "nutrition", "stress"
    let duration: TimeInterval?
    
    // Analysis
    let detectedMood: String?
    let emotionTags: [String]  // e.g., ["stressed", "motivated", "tired"]
    let keyInsights: [String]?
    let suggestedActions: [VapiAction]?
    
    // Recording
    let recordingURL: URL?
    let transcriptURL: URL?
    let transcriptText: String?
    
    let createdAt: Date
}

struct Message {
    let id: UUID
    let conversationId: UUID
    
    let role: MessageRole  // user, assistant, system
    let content: String
    let contentType: ContentType  // text, voice
    
    // For user messages
    let detectedEmotion: String?
    let emotionConfidence: Double?
    
    // For assistant messages
    let suggestedActions: [VapiAction]?
    
    let timestamp: Date
}

enum MessageRole {
    case user
    case assistant
    case system
}

enum ContentType {
    case text
    case voice
}

struct VapiAction {
    let name: String  // e.g., "set_reminder", "enable_focus_mode"
    let parameters: [String: Any]
    let status: ActionStatus  // pending, executed, failed, skipped
}

enum ActionStatus {
    case pending
    case executed
    case failed
    case skipped
}
```

### Habit

```swift
struct Habit {
    let id: UUID
    let userId: UUID
    
    let name: String
    let description: String?
    let category: String  // exercise, meditation, hydration, nutrition, sleep
    
    // Target
    let frequencyPerWeek: Int
    let targetDuration: Int?  // minutes
    
    // Progress
    let startDate: Date
    let completions: [HabitCompletion]
    
    // Stats
    var currentStreak: Int
    var longestStreak: Int
    var completionRate: Double  // 0-100
    
    // Reminder
    let reminderTime: Date?
    let reminderEnabled: Bool
    
    // Status
    let isActive: Bool
    let linkedGoal: UUID?
    
    let createdAt: Date
    let updatedAt: Date
}

struct HabitCompletion {
    let id: UUID
    let habitId: UUID
    let date: Date
    let completedAt: Date
    let duration: Int?  // minutes
    let notes: String?
}
```

### WeeklyReport

```swift
struct WeeklyReport {
    let id: UUID
    let userId: UUID
    let weekStartDate: Date
    
    // Energy trends
    let bodyBatteryTrend: [Int]  // Array of 7 daily avg scores
    let energyConsistency: Double  // 0-100
    let recoveryQuality: Double  // 0-100
    
    // Habits
    let habitsCompleted: Int
    let habitsAttempted: Int
    let habitCompletionRate: Double
    let newHabitsFormed: [String]?
    
    // Emotional analysis
    let predominantEmotions: [String]
    let anxietyInstances: Int
    let stressedInstances: Int
    let happyInstances: Int
    let motivationLevel: Double  // 0-100
    
    // Focus & boundaries
    let focusModeHours: Int
    let distractionInstances: Int
    let boundaryAdherence: Double  // 0-100
    
    // Nutrition
    let mealsLogged: Int
    let healthyMealPercentage: Double  // 0-100
    let macroBalance: [String: Double]?
    
    // Personal growth
    let keyAchievements: [String]
    let areasForImprovement: [String]
    let narrativeFromCoach: String  // Personalized coach summary
    
    // Recommendations
    let recommendedFocusAreas: [String]
    let nextWeekGoals: [String]
    
    let createdAt: Date
}
```

### MonthlyReport

```swift
struct MonthlyReport {
    let id: UUID
    let userId: UUID
    let monthStartDate: Date
    
    // Deep trends
    let bodyBatteryTrend: [Int]  // Array of ~30 daily avg scores
    let energyPattern: EnergyPattern
    let burnoutRiskLevel: Double  // 0-100
    let recoveryCapacity: Double  // 0-100
    
    // Lifestyle analysis
    let productivityHours: Int
    let restHours: Int
    let balanceRatio: Double  // productivity:rest
    let consistencyScore: Double  // 0-100
    
    // Health metrics
    let avgSleepPerNight: TimeInterval
    let avgActivity: Int  // daily average steps or calories
    let nutritionScore: Double  // 0-100
    let hydrationAverage: Int?  // glasses per day
    
    // Emotional resilience
    let emotionalStabilityScore: Double  // 0-100
    let stressResponseTime: String?  // how quickly user recovered
    let selfTalkAnalysis: SelfTalkAnalysis
    let positivityTrend: Double  // -100 to +100, improvement direction
    
    // Behavioral patterns
    let highPerformanceHours: [Int]?  // hours of day when most productive
    let lowEnergyPatterns: [String]?  // triggers for energy drops
    let successPatterns: [String]?  // what enables good days
    
    // Habits
    let habitFormationSuccess: Int  // count of habits successfully formed
    let habitSustainability: Double  // 0-100, how many old habits maintained
    
    // Personal growth
    let identityReinforcement: String  // Coach's message about user's identity shift
    let progressMilestones: [String]
    let monthlyNarrative: String
    
    let createdAt: Date
}

struct EnergyPattern {
    let pattern: String  // "consistent", "declining", "recovering", "volatile"
    let averageScore: Int
    let peakDay: Date?
    let lowestDay: Date?
}

struct SelfTalkAnalysis {
    let negativePhraseCount: Int
    let positivePhraseCount: Int
    let selfCriticismInstances: Int
    let selfCompassionInstances: Int
    let improvementPercentage: Double  // vs. previous month
    let topNegativePatterns: [String]
    let topPositivePatterns: [String]
}
```

## Persistence Layer

### Storage Strategy
- **Local**: SwiftData (SQLite) for all models
- **Cloud** (future): iCloud CloudKit for backup and sync
- **Encryption**: User data encrypted at rest using Keychain for sensitive fields

### Retention Policy
- **Conversations**: Keep indefinitely (but allow deletion)
- **BodyBattery snapshots**: Keep all (lightweight)
- **Meals**: Keep all photos locally for 90 days, metadata indefinitely
- **Daily/Weekly/Monthly reports**: Keep indefinitely
- **User profile**: Keep as long as account active

### Privacy
- No PII in logs
- Emotion data stored locally only
- Recording/transcripts encrypted
- Deletion cascade when user deletes account

## Repository Patterns

### BodyBatteryRepository

```swift
protocol BodyBatteryRepository {
    func save(_ snapshot: BodyBatterySnapshot) async throws
    func getLatest(userId: UUID) -> BodyBatterySnapshot?
    func getDaily(userId: UUID, date: Date) -> BodyBatteryDaily?
    func getWeekly(userId: UUID, weekStart: Date) -> BodyBatteryWeekly?
    func getAllSnapshots(userId: UUID, from: Date, to: Date) -> [BodyBatterySnapshot]
}
```

### ConversationRepository

```swift
protocol ConversationRepository {
    func save(_ conversation: Conversation) async throws
    func getById(_ id: UUID) -> Conversation?
    func getAllForUser(_ userId: UUID, limit: Int?) -> [Conversation]
    func getByDateRange(_ userId: UUID, from: Date, to: Date) -> [Conversation]
    func delete(_ id: UUID) async throws
    func deleteAllForUser(_ userId: UUID) async throws
}
```

### MealRepository

```swift
protocol MealRepository {
    func save(_ meal: Meal) async throws
    func getById(_ id: UUID) -> Meal?
    func getForUser(_ userId: UUID, limit: Int?) -> [Meal]
    func getByDateRange(_ userId: UUID, from: Date, to: Date) -> [Meal]
    func getByMealType(_ userId: UUID, type: String) -> [Meal]
    func delete(_ id: UUID) async throws
}
```

