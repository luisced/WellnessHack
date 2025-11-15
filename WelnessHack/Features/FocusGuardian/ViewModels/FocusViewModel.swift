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
    
    // TODO: BACKEND - Agregar FocusTimer cuando se implemente
    // private var focusTimer: FocusTimer?
    
    // TODO: BACKEND - Agregar FocusSessionManager
    // private var sessionManager: FocusSessionManager?
    
    // TODO: BACKEND - Agregar FocusNotificationManager
    // private var notificationManager: FocusNotificationManager?
    
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
        
        // TODO: BACKEND - Implementar timer real
        /*
        do {
            // 1. Solicitar permisos de notificaciones
            try await notificationManager?.requestPermissions()
            
            // 2. Configurar timer
            focusTimer = FocusTimer()
            focusTimer?.onTick = { [weak self] remainingTime in
                Task { @MainActor in
                    self?.timeRemaining = remainingTime
                }
            }
            
            focusTimer?.onComplete = { [weak self] in
                Task { @MainActor in
                    self?.completeSession()
                }
            }
            
            // 3. Iniciar timer
            try focusTimer?.startTimer(duration: totalTime)
            
            // 4. Programar notificación
            try await notificationManager?.scheduleSessionEndNotification(
                in: totalTime,
                message: "¡Sesión de focus completada! Tiempo para un break."
            )
            
        } catch {
            handleError(error)
        }
        */
        
        // MOCK: Simular timer para UI testing
        simulateTimer()
        
        print("🎯 [MOCK] Sesión de focus iniciada - 25 minutos")
    }
    
    /// Pausa o reanuda la sesión actual
    func togglePause() {
        isTimerActive.toggle()
        
        if isTimerActive {
            focusState = .focusing
            // TODO: BACKEND - Reanudar timer real
            // focusTimer?.resumeTimer()
            print("▶️ [MOCK] Timer reanudado")
        } else {
            focusState = .paused
            // TODO: BACKEND - Pausar timer real
            // focusTimer?.pauseTimer()
            print("⏸️ [MOCK] Timer pausado")
        }
    }
    
    /// Detiene la sesión actual
    func stopSession() {
        focusState = .idle
        isTimerActive = false
        
        // TODO: BACKEND - Detener timer y cancelar notificaciones
        /*
        focusTimer?.stopTimer()
        focusTimer = nil
        
        Task {
            await notificationManager?.cancelNotifications()
        }
        */
        
        // Resetear estado
        timeRemaining = totalTime
        
        print("🛑 [MOCK] Sesión detenida")
    }
    
    /// Inicia un break (descanso corto o largo)
    func startBreakSession(isLongBreak: Bool = false) {
        focusState = .onBreak
        sessionType = isLongBreak ? .longBreak : .shortBreak
        totalTime = isLongBreak ? 900 : 300 // 15 min o 5 min
        timeRemaining = totalTime
        isTimerActive = true
        
        // TODO: BACKEND - Implementar timer de break
        // Similar a startFocusSession() pero con duración diferente
        
        // MOCK: Simular break timer
        simulateTimer()
        
        print("☕ [MOCK] Break iniciado - \(isLongBreak ? "15" : "5") minutos")
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
            
            // TODO: BACKEND - Guardar sesión completada
            // sessionManager?.saveCompletedSession(type: .focus, duration: totalTime)
            
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
        
        print("✅ [MOCK] Sesión completada: \(sessionType)")
    }
    
    private func simulateTimer() {
        // MOCK: Simular countdown para testing UI
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            Task { @MainActor in
                if self.isTimerActive && self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else if self.timeRemaining <= 0 {
                    timer.invalidate()
                    self.completeSession()
                } else if !self.isTimerActive {
                    // Timer pausado, no hacer nada
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

// MARK: - TODO: Backend Implementation Notes

/*
 BACKEND PENDIENTE - Implementaciones necesarias:
 
 1. FocusTimer.swift
    - Timer real con precisión
    - Manejo de background/foreground
    - Callbacks: onTick, onComplete, onPause, onResume
    - Métodos: startTimer(), pauseTimer(), resumeTimer(), stopTimer()
 
 2. FocusSessionManager.swift
    - Lógica de pomodoro (25/5/15 minutos)
    - Contador de sesiones diarias
    - Decisión de break corto vs largo
    - Métodos: saveSession(), loadTodayStats(), shouldTakeLongBreak()
 
 3. FocusNotificationManager.swift
    - Solicitar permisos de notificaciones
    - Programar notificación al finalizar sesión
    - Cancelar notificaciones si se detiene manualmente
    - Sonidos personalizados para focus vs break
 
 4. FocusStore.swift
    - Persistencia de sesiones (UserDefaults o CoreData)
    - Estadísticas históricas
    - Configuración de duraciones personalizadas
    - Export de datos para análisis
 
 5. Permisos en Info.plist:
    - NSUserNotificationsUsageDescription
    - Descripción: "Para notificarte cuando termine tu sesión de focus"
 
 6. Background App Refresh:
    - Configurar para que el timer siga corriendo en background
    - Manejar transiciones foreground/background
    - Sincronizar estado al volver a la app
 
 7. Integración con HealthKit (opcional):
    - Registrar tiempo de mindfulness
    - Datos de productividad/focus time
    - Correlación con otros datos de salud
 */
