import Foundation

/// Perfil del usuario con información recopilada durante el onboarding
struct UserProfile: Codable {
    // MARK: - Basic Info
    var name: String?
    var age: Int?
    
    // MARK: - Wellness Goals
    var primaryGoal: WellnessGoal?
    var secondaryGoals: [WellnessGoal] = []
    
    // MARK: - Health Context
    var currentEnergyLevel: EnergyLevel?
    var sleepQuality: SleepQuality?
    var stressLevel: StressLevel?
    var activityLevel: ActivityLevel?
    
    // MARK: - Health Conditions
    var healthConditions: [String] = []
    var medications: [String] = []
    
    // MARK: - Preferences
    var preferredLanguage: String = "es"
    var notificationsEnabled: Bool = true
    var reminderTimes: [String] = []
    
    // MARK: - Onboarding State
    var onboardingCompleted: Bool = false
    var onboardingDate: Date?
    var lastUpdated: Date = Date()
    
    // MARK: - Initialization
    init() {
        self.lastUpdated = Date()
    }
}

// MARK: - Wellness Goal Enum

enum WellnessGoal: String, Codable, CaseIterable {
    case improveSleep = "improve_sleep"
    case increaseEnergy = "increase_energy"
    case reduceStress = "reduce_stress"
    case betterFocus = "better_focus"
    case moreActive = "more_active"
    case balanceLife = "balance_life"
    case betterMood = "better_mood"
    
    var displayName: String {
        switch self {
        case .improveSleep: return "Mejorar el sueño"
        case .increaseEnergy: return "Aumentar energía"
        case .reduceStress: return "Reducir estrés"
        case .betterFocus: return "Mejorar concentración"
        case .moreActive: return "Ser más activo"
        case .balanceLife: return "Equilibrar vida"
        case .betterMood: return "Mejorar estado de ánimo"
        }
    }
    
    var emoji: String {
        switch self {
        case .improveSleep: return "😴"
        case .increaseEnergy: return "⚡️"
        case .reduceStress: return "🧘"
        case .betterFocus: return "🎯"
        case .moreActive: return "🏃"
        case .balanceLife: return "⚖️"
        case .betterMood: return "😊"
        }
    }
}

// MARK: - Energy Level Enum

enum EnergyLevel: String, Codable {
    case veryLow = "very_low"
    case low = "low"
    case moderate = "moderate"
    case high = "high"
    case veryHigh = "very_high"
    
    var displayName: String {
        switch self {
        case .veryLow: return "Muy baja"
        case .low: return "Baja"
        case .moderate: return "Moderada"
        case .high: return "Alta"
        case .veryHigh: return "Muy alta"
        }
    }
}

// MARK: - Sleep Quality Enum

enum SleepQuality: String, Codable {
    case veryPoor = "very_poor"
    case poor = "poor"
    case fair = "fair"
    case good = "good"
    case excellent = "excellent"
    
    var displayName: String {
        switch self {
        case .veryPoor: return "Muy mala"
        case .poor: return "Mala"
        case .fair: return "Regular"
        case .good: return "Buena"
        case .excellent: return "Excelente"
        }
    }
}

// MARK: - Stress Level Enum

enum StressLevel: String, Codable {
    case minimal = "minimal"
    case low = "low"
    case moderate = "moderate"
    case high = "high"
    case veryHigh = "very_high"
    
    var displayName: String {
        switch self {
        case .minimal: return "Mínimo"
        case .low: return "Bajo"
        case .moderate: return "Moderado"
        case .high: return "Alto"
        case .veryHigh: return "Muy alto"
        }
    }
}

// MARK: - Activity Level Enum

enum ActivityLevel: String, Codable {
    case sedentary = "sedentary"
    case lightlyActive = "lightly_active"
    case moderatelyActive = "moderately_active"
    case veryActive = "very_active"
    case extremelyActive = "extremely_active"
    
    var displayName: String {
        switch self {
        case .sedentary: return "Sedentario"
        case .lightlyActive: return "Ligeramente activo"
        case .moderatelyActive: return "Moderadamente activo"
        case .veryActive: return "Muy activo"
        case .extremelyActive: return "Extremadamente activo"
        }
    }
}
