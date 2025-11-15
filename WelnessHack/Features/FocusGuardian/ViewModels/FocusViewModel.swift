import Foundation
import SwiftUI
import Combine

/// ViewModel para manejar el estado y lógica del FocusScreen
@MainActor
class FocusViewModel: ObservableObject {
    
    // MARK: - Published Properties (UI State)
    
    /// Estado actual de la sesión de focus
    @Published var focusState: FocusState = .idle
    
    /// Tiempo restante en la sesión actual (en segundos)
    @Published var timeRemaining: TimeInterval = 1500 // 25 minutos por defecto
    
    /// Duración total de la sesión actual
    @Published var totalTime: TimeInterval = 1500
    
    /// Indica si el timer está activo/corriendo
    @Published var isTimerActive: Bool = false
    
    /// Tipo de sesión actual
    @Published var sessionType: SessionType = .focus
    
    /// Número de sesiones completadas hoy
    @Published var completedSessions: Int = 0
    
    /// Mensajes motivacionales actuales
    @Published var currentMessages: [String] = []
    
    /// Indica si hay un error
    @Published var showError: Bool = false
    
    /// Mensaje de error para mostrar
    @Published var errorMessage: String = ""
    
    /// Battery level (0.0 to 1.0)
    @Published var batteryLevel: Double = 0.0
    
    /// Current body battery snapshot
    @Published var currentBodyBattery: BodyBatterySnapshot?
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    private let healthKitManager = HealthKitManager.shared
    private let bodyBatteryCalculator = BodyBatteryCalculator()
    
    // MARK: - Initialization
    
    init() {
        setupInitialState()
        loadMotivationalMessages()
        
        // Load battery level data
        Task {
            await loadBatteryLevel()
        }
    }
    
    // MARK: - Public Methods
    
    /// Inicia una nueva sesión de focus
    func startFocusSession() {
        focusState = .focusing
        isTimerActive = true
        sessionType = .focus
        totalTime = 1500 // 25 minutos
        timeRemaining = totalTime
        simulateTimer()
    }
    
    /// Pausa o reanuda la sesión actual
    func togglePause() {
        isTimerActive.toggle()
        
        if isTimerActive {
            focusState = .focusing
            print("▶️ Timer reanudado")
        } else {
            focusState = .paused
            print("⏸️ Timer pausado")
        }
    }
    
    /// Detiene la sesión actual
    func stopSession() {
        focusState = .idle
        isTimerActive = false
        timeRemaining = totalTime
    }
    
    /// Inicia un break (descanso corto o largo)
    func startBreakSession(isLongBreak: Bool = false) {
        focusState = .onBreak
        sessionType = isLongBreak ? .longBreak : .shortBreak
        totalTime = isLongBreak ? 900 : 300 // 15 min o 5 min
        timeRemaining = totalTime
        isTimerActive = true
        simulateTimer()
    }
    
    /// Simula que el reloj fue tocado (transición idle → focusing)
    func onClockTapped() {
        guard focusState == .idle else { return }
        
        withAnimation(.easeInOut(duration: 0.8)) {
            startFocusSession()
        }
    }
    
    // MARK: - Private Methods
    
    private func setupInitialState() {
        focusState = .idle
        timeRemaining = 1500
        totalTime = 1500
        isTimerActive = false
        completedSessions = UserDefaults.standard.integer(forKey: "focus_sessions_today")
    }
    
    func loadMotivationalMessages() {
        switch sessionType {
        case .focus:
            currentMessages = MotivationalMessages.focusMessages
        case .shortBreak, .longBreak:
            currentMessages = MotivationalMessages.breakMessages
        }
    }
    
    private func completeSession() {
        switch sessionType {
        case .focus:
            completedSessions += 1
            UserDefaults.standard.set(completedSessions, forKey: "focus_sessions_today")
            
            // Decidir si es break corto o largo
            let shouldTakeLongBreak = completedSessions % 4 == 0
            
            // Iniciar break automáticamente
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.startBreakSession(isLongBreak: shouldTakeLongBreak)
            }
            
        case .shortBreak, .longBreak:
            // Volver al estado idle después del break
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.focusState = .idle
                self.isTimerActive = false
                self.timeRemaining = 1500
                self.totalTime = 1500
                self.sessionType = .focus
            }
        }
    }
    
    private func simulateTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            Task { @MainActor in
                if self.isTimerActive && self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else if self.timeRemaining <= 0 {
                    timer.invalidate()
                    self.completeSession()
                }
            }
        }
    }
    
    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true
        focusState = .idle
        isTimerActive = false
        print("❌ Error: \(error.localizedDescription)")
    }
    
    // MARK: - Battery Level Loading
    
    private func loadBatteryLevel() async {
        // Fetch health data (handle errors gracefully)
        let sleepData = try? await healthKitManager.fetchLastNightSleep()
        let hrvAverage = try? await healthKitManager.fetchAverageHRV()
        let activityData = try? await healthKitManager.fetchActivitySummary()
        
        // Calculate body battery (even with partial data)
        currentBodyBattery = bodyBatteryCalculator.calculateBodyBattery(
            sleepData: sleepData,
            hrvAverage: hrvAverage,
            activityData: activityData
        )
        
        // Update battery level (0.0 - 1.0)
        if let battery = currentBodyBattery {
            batteryLevel = Double(battery.score) / 100.0
        }
        
        print("✅ Battery level loaded in FocusScreen: \(currentBodyBattery?.score ?? 0)/100")
    }
    
    /// Refresh battery level data
    func refreshBatteryLevel() async {
        await loadBatteryLevel()
    }
}

// MARK: - Supporting Types

/// Estados posibles de la sesión de focus
enum FocusState {
    case idle           // Sin sesión activa, mostrando reloj
    case focusing       // Sesión de focus activa
    case paused         // Sesión pausada
    case onBreak        // En descanso (break)
}

/// Tipos de sesión
enum SessionType {
    case focus          // Sesión de trabajo/focus (25 min)
    case shortBreak     // Descanso corto (5 min)
    case longBreak      // Descanso largo (15 min)
    
    var displayName: String {
        switch self {
        case .focus: return "FOCUS TIME"
        case .shortBreak: return "SHORT BREAK"
        case .longBreak: return "LONG BREAK"
        }
    }
    
    var defaultDuration: TimeInterval {
        switch self {
        case .focus: return 1500      // 25 minutos
        case .shortBreak: return 300  // 5 minutos
        case .longBreak: return 900   // 15 minutos
        }
    }
}
