import Foundation

/// Manager para manejar el flujo de onboarding conversacional
class OnboardingManager: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var userProfile: UserProfile = UserProfile()
    @Published var isOnboardingComplete: Bool = false
    @Published var currentStep: OnboardingStep = .welcome
    
    // MARK: - Private Properties
    
    private let userDefaults = UserDefaults.standard
    private let profileKey = "user_profile"
    private let onboardingCompleteKey = "onboarding_complete"
    
    // MARK: - Singleton
    
    static let shared = OnboardingManager()
    
    // MARK: - Initialization
    
    private init() {
        // Load existing profile or create new one
        if let data = userDefaults.data(forKey: profileKey),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            self.userProfile = profile
            self.isOnboardingComplete = profile.onboardingCompleted
        }
    }
    
    // MARK: - Profile Management
    
    @MainActor
    func saveProfile() {
        userProfile.lastUpdated = Date()
        
        if let encoded = try? JSONEncoder().encode(userProfile) {
            userDefaults.set(encoded, forKey: profileKey)
            userDefaults.set(userProfile.onboardingCompleted, forKey: onboardingCompleteKey)
            print("✅ User profile saved")
        }
    }
    
    @MainActor
    func updateProfile(_ updates: (inout UserProfile) -> Void) {
        updates(&userProfile)
        saveProfile()
    }
    
    @MainActor
    func completeOnboarding() {
        userProfile.onboardingCompleted = true
        userProfile.onboardingDate = Date()
        isOnboardingComplete = true
        saveProfile()
        print("🎉 Onboarding completed!")
    }
    
    @MainActor
    func resetOnboarding() {
        userProfile = UserProfile()
        isOnboardingComplete = false
        currentStep = .welcome
        userDefaults.removeObject(forKey: profileKey)
        userDefaults.removeObject(forKey: onboardingCompleteKey)
        print("🔄 Onboarding reset")
    }
    
    // MARK: - Onboarding Flow
    
    @MainActor
    func moveToNextStep() {
        currentStep = currentStep.next()
    }
    
    func getOnboardingPrompt() -> String {
        return currentStep.prompt
    }
    
    // MARK: - Context for AI
    
    func getOnboardingContext() -> [String: Any] {
        return [
            "onboarding_active": !isOnboardingComplete,
            "current_step": currentStep.rawValue,
            "profile_completion": getProfileCompletion(),
            "collected_info": getCollectedInfo()
        ]
    }
    
    private func getProfileCompletion() -> Double {
        var completed = 0
        let total = 8
        
        if userProfile.name != nil { completed += 1 }
        if userProfile.age != nil { completed += 1 }
        if userProfile.primaryGoal != nil { completed += 1 }
        if userProfile.currentEnergyLevel != nil { completed += 1 }
        if userProfile.sleepQuality != nil { completed += 1 }
        if userProfile.stressLevel != nil { completed += 1 }
        if userProfile.activityLevel != nil { completed += 1 }
        if !userProfile.healthConditions.isEmpty { completed += 1 }
        
        return Double(completed) / Double(total)
    }
    
    private func getCollectedInfo() -> [String: Any] {
        var info: [String: Any] = [:]
        
        if let name = userProfile.name {
            info["name"] = name
        }
        if let age = userProfile.age {
            info["age"] = age
        }
        if let goal = userProfile.primaryGoal {
            info["primary_goal"] = goal.displayName
        }
        if let energy = userProfile.currentEnergyLevel {
            info["energy_level"] = energy.displayName
        }
        if let sleep = userProfile.sleepQuality {
            info["sleep_quality"] = sleep.displayName
        }
        if let stress = userProfile.stressLevel {
            info["stress_level"] = stress.displayName
        }
        if let activity = userProfile.activityLevel {
            info["activity_level"] = activity.displayName
        }
        
        return info
    }
}

// MARK: - Onboarding Steps

enum OnboardingStep: String, Codable {
    case welcome = "welcome"
    case name = "name"
    case age = "age"
    case primaryGoal = "primary_goal"
    case energyLevel = "energy_level"
    case sleepQuality = "sleep_quality"
    case stressLevel = "stress_level"
    case activityLevel = "activity_level"
    case healthConditions = "health_conditions"
    case summary = "summary"
    case complete = "complete"
    
    var prompt: String {
        switch self {
        case .welcome:
            return """
            ¡Hola! Soy tu asistente de wellness. Estoy aquí para ayudarte a mejorar tu energía y bienestar. 
            Para poder darte las mejores recomendaciones, me gustaría conocerte mejor. 
            ¿Empezamos? ¿Cómo te llamas?
            """
        case .name:
            return "Perfecto, encantado de conocerte. ¿Cuántos años tienes?"
        case .age:
            return """
            Genial. Ahora dime, ¿cuál es tu objetivo principal? Por ejemplo:
            - Mejorar tu sueño
            - Aumentar tu energía
            - Reducir el estrés
            - Mejorar tu concentración
            - Ser más activo
            """
        case .primaryGoal:
            return "Excelente objetivo. ¿Cómo describirías tu nivel de energía actualmente? ¿Muy bajo, bajo, moderado, alto o muy alto?"
        case .energyLevel:
            return "Entiendo. ¿Y cómo ha sido la calidad de tu sueño últimamente? ¿Muy mala, mala, regular, buena o excelente?"
        case .sleepQuality:
            return "¿Cómo describirías tu nivel de estrés? ¿Mínimo, bajo, moderado, alto o muy alto?"
        case .stressLevel:
            return "¿Qué tan activo eres físicamente? ¿Sedentario, ligeramente activo, moderadamente activo, muy activo o extremadamente activo?"
        case .activityLevel:
            return "¿Tienes alguna condición de salud o tomas algún medicamento que deba conocer? Si no, solo dime 'ninguna'."
        case .healthConditions:
            return """
            Perfecto, déjame resumir lo que me has contado:
            - Objetivo: [goal]
            - Energía: [energy]
            - Sueño: [sleep]
            - Estrés: [stress]
            - Actividad: [activity]
            
            ¿Es correcto? Si quieres cambiar algo, dímelo. Si está bien, empecemos a trabajar juntos.
            """
        case .summary:
            return "¡Excelente! Ya estamos listos. Ahora puedo ayudarte mejor. ¿En qué te puedo ayudar hoy?"
        case .complete:
            return ""
        }
    }
    
    func next() -> OnboardingStep {
        switch self {
        case .welcome: return .name
        case .name: return .age
        case .age: return .primaryGoal
        case .primaryGoal: return .energyLevel
        case .energyLevel: return .sleepQuality
        case .sleepQuality: return .stressLevel
        case .stressLevel: return .activityLevel
        case .activityLevel: return .healthConditions
        case .healthConditions: return .summary
        case .summary: return .complete
        case .complete: return .complete
        }
    }
}
