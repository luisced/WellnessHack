import Foundation
import SwiftUI
import EventKit
import Combine

/// ViewModel para manejar el estado y lógica del CalendarScreen
@MainActor
class CalendarViewModel: ObservableObject {
    
    // MARK: - Published Properties (UI State)
    
    /// Fecha actualmente seleccionada
    @Published var selectedDate: Date = Date()
    
    /// Mes actualmente mostrado en el calendario
    @Published var currentMonth: Date = Date()
    
    /// Eventos del día seleccionado
    @Published var todayEvents: [CalendarEvent] = []
    
    /// Todos los eventos del mes actual
    @Published var monthEvents: [CalendarEvent] = []
    
    /// Indica si se está cargando información
    @Published var isLoading: Bool = false
    
    /// Indica si hay un error
    @Published var showError: Bool = false
    
    /// Mensaje de error para mostrar
    @Published var errorMessage: String = ""
    
    /// Indica si se tiene acceso al calendario del sistema
    @Published var hasCalendarAccess: Bool = false
    
    /// Vista actual del calendario (mes, semana, día)
    @Published var calendarViewMode: CalendarViewMode = .week
    
    /// Días mostrados actualmente (3 días)
    @Published var currentDisplayDays: [Date] = []
    
    /// Fecha central de la vista de 3 días
    @Published var centerDate: Date = Date()
    
    /// Rango de horas visible (ajustable por el usuario)
    @Published var startHour: Int = 6
    @Published var endHour: Int = 22
    
    /// Eventos organizados por día y hora para la vista semanal
    @Published var weeklyEvents: [Date: [Int: [CalendarEvent]]] = [:]
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    private let calendar = Calendar.current
    
    // MARK: - Initialization
    
    init() {
        setupInitialState()
        setupCurrentDays()
        loadMockEvents()
    }
    
    // MARK: - Public Methods
    
    /// Solicita permisos de acceso al calendario del sistema
    func requestCalendarAccess() async {
        // TODO: BACKEND - Implementar solicitud de permisos EventKit
        /*
        do {
            let eventStore = EKEventStore()
            
            if #available(iOS 17.0, *) {
                let granted = try await eventStore.requestFullAccessToEvents()
                hasCalendarAccess = granted
            } else {
                // Fallback para iOS 16 y anteriores
                let status = EKEventStore.authorizationStatus(for: .event)
                hasCalendarAccess = (status == .authorized)
            }
            
            if hasCalendarAccess {
                await loadSystemEvents()
            }
        } catch {
            handleError(error)
        }
        */
        
        // MOCK: Simular permisos concedidos
        hasCalendarAccess = true
        print("📅 [MOCK] Permisos de calendario concedidos")
    }
    
    /// Cambia el mes mostrado en el calendario
    func changeMonth(by offset: Int) {
        let calendar = Calendar.current
        if let newMonth = calendar.date(byAdding: .month, value: offset, to: currentMonth) {
            currentMonth = newMonth
            loadEventsForMonth(newMonth)
        }
    }
    
    /// Selecciona una fecha específica
    func selectDate(_ date: Date) {
        selectedDate = date
        loadEventsForDate(date)
    }
    
    /// Cambia el modo de vista del calendario
    func changeViewMode(_ mode: CalendarViewMode) {
        calendarViewMode = mode
    }
    
    /// Navega 3 días hacia atrás
    func goToPreviousDays() {
        if let newCenterDate = calendar.date(byAdding: .day, value: -3, to: centerDate) {
            centerDate = newCenterDate
            setupCurrentDays()
            organizeEventsForDays()
        }
    }
    
    /// Navega 3 días hacia adelante
    func goToNextDays() {
        if let newCenterDate = calendar.date(byAdding: .day, value: 3, to: centerDate) {
            centerDate = newCenterDate
            setupCurrentDays()
            organizeEventsForDays()
        }
    }
    
    /// Ajusta el rango de horas visible
    func adjustHourRange(startHour: Int, endHour: Int) {
        self.startHour = max(0, min(startHour, 23))
        self.endHour = max(self.startHour + 1, min(endHour, 23))
    }
    
    /// Obtiene eventos para un día y hora específicos
    func getEvents(for date: Date, hour: Int) -> [CalendarEvent] {
        let dayKey = calendar.startOfDay(for: date)
        return weeklyEvents[dayKey]?[hour] ?? []
    }
    
    /// Agrega un nuevo evento (solo para consistencia de API)
    func addEvent(title: String, date: Date, duration: TimeInterval = 3600) async {
        // No hace nada - eventos son solo de lectura
        print("📅 Los eventos son solo de lectura en esta versión")
    }
    
    /// Elimina un evento (solo para consistencia de API)
    func deleteEvent(_ event: CalendarEvent) async {
        // No hace nada - eventos son solo de lectura
        print("📅 Los eventos son solo de lectura en esta versión")
    }
    
    /// Actualiza un evento (solo para consistencia de API)
    func updateEvent(_ event: CalendarEvent) async {
        // No hace nada - eventos son solo de lectura
        print("📅 Los eventos son solo de lectura en esta versión")
    }
    
    // MARK: - Private Methods
    
    private func setupInitialState() {
        selectedDate = Date()
        currentMonth = Date()
        hasCalendarAccess = false
        calendarViewMode = .week
    }
    
    func setupCurrentDays() {
        // Generar 3 días: día anterior, día central, día siguiente
        currentDisplayDays = (-1...1).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: centerDate)
        }
    }
    
    func organizeEventsForDays() {
        weeklyEvents.removeAll()
        
        for event in monthEvents {
            let eventDay = calendar.startOfDay(for: event.startDate)
            let eventHour = calendar.component(.hour, from: event.startDate)
            
            // Solo incluir eventos de los 3 días actuales
            if currentDisplayDays.contains(where: { calendar.isDate($0, inSameDayAs: eventDay) }) {
                if weeklyEvents[eventDay] == nil {
                    weeklyEvents[eventDay] = [:]
                }
                
                if weeklyEvents[eventDay]![eventHour] == nil {
                    weeklyEvents[eventDay]![eventHour] = []
                }
                
                weeklyEvents[eventDay]![eventHour]!.append(event)
            }
        }
    }
    
    private func loadMockEvents() {
        // Eventos del 14 al 20 de Noviembre 2025
        let calendar = Calendar.current
        var mockEvents: [CalendarEvent] = []
        
        // Crear componentes para noviembre 2025
        var dateComponents = DateComponents()
        dateComponents.year = 2025
        dateComponents.month = 11
        
        // 14 de Noviembre - Viernes (4 eventos)
        dateComponents.day = 14
        if let day = calendar.date(from: dateComponents) {
            mockEvents.append(CalendarEvent(
                title: "Morning Workout",
                startDate: calendar.date(byAdding: .hour, value: 7, to: calendar.startOfDay(for: day))!,
                endDate: calendar.date(byAdding: .hour, value: 8, to: calendar.startOfDay(for: day))!,
                location: "Gym",
                source: .healthKit
            ))
            mockEvents.append(CalendarEvent(
                title: "Team Standup",
                startDate: calendar.date(byAdding: .hour, value: 10, to: calendar.startOfDay(for: day))!,
                endDate: calendar.date(byAdding: .hour, value: 10, to: calendar.startOfDay(for: day))! + 1800,
                location: "Conference Room A",
                source: .system
            ))
            mockEvents.append(CalendarEvent(
                title: "Focus Time",
                startDate: calendar.date(byAdding: .hour, value: 14, to: calendar.startOfDay(for: day))!,
                endDate: calendar.date(byAdding: .hour, value: 16, to: calendar.startOfDay(for: day))!,
                notes: "Deep work session",
                source: .ai
            ))
            mockEvents.append(CalendarEvent(
                title: "Dinner with Team",
                startDate: calendar.date(byAdding: .hour, value: 19, to: calendar.startOfDay(for: day))!,
                endDate: calendar.date(byAdding: .hour, value: 21, to: calendar.startOfDay(for: day))!,
                location: "Downtown Restaurant",
                source: .user
            ))
        }
        
        // 15 de Noviembre - Sábado (2 eventos)
        dateComponents.day = 15
        if let day = calendar.date(from: dateComponents) {
            mockEvents.append(CalendarEvent(
                title: "Yoga Session",
                startDate: calendar.date(byAdding: .hour, value: 9, to: calendar.startOfDay(for: day))!,
                endDate: calendar.date(byAdding: .hour, value: 10, to: calendar.startOfDay(for: day))!,
                location: "Home",
                source: .healthKit
            ))
            mockEvents.append(CalendarEvent(
                title: "Family Brunch",
                startDate: calendar.date(byAdding: .hour, value: 12, to: calendar.startOfDay(for: day))!,
                endDate: calendar.date(byAdding: .hour, value: 14, to: calendar.startOfDay(for: day))!,
                location: "Home",
                source: .user
            ))
        }
        
        // 16 de Noviembre - Domingo (SIN EVENTOS)
        
        // 17 de Noviembre - Lunes (3 eventos)
        dateComponents.day = 17
        if let day = calendar.date(from: dateComponents) {
            mockEvents.append(CalendarEvent(
                title: "Morning Run",
                startDate: calendar.date(byAdding: .hour, value: 6, to: calendar.startOfDay(for: day))!,
                endDate: calendar.date(byAdding: .hour, value: 7, to: calendar.startOfDay(for: day))!,
                notes: "5K route",
                source: .healthKit
            ))
            mockEvents.append(CalendarEvent(
                title: "Product Review",
                startDate: calendar.date(byAdding: .hour, value: 11, to: calendar.startOfDay(for: day))!,
                endDate: calendar.date(byAdding: .hour, value: 12, to: calendar.startOfDay(for: day))!,
                location: "Zoom",
                source: .system
            ))
            mockEvents.append(CalendarEvent(
                title: "Client Presentation",
                startDate: calendar.date(byAdding: .hour, value: 15, to: calendar.startOfDay(for: day))!,
                endDate: calendar.date(byAdding: .hour, value: 16, to: calendar.startOfDay(for: day))! + 1800,
                location: "Meeting Room B",
                source: .system
            ))
        }
        
        // 18 de Noviembre - Martes (4 eventos)
        dateComponents.day = 18
        if let day = calendar.date(from: dateComponents) {
            mockEvents.append(CalendarEvent(
                title: "Meditation",
                startDate: calendar.date(byAdding: .hour, value: 7, to: calendar.startOfDay(for: day))!,
                endDate: calendar.date(byAdding: .hour, value: 7, to: calendar.startOfDay(for: day))! + 1800,
                notes: "Mindfulness practice",
                source: .ai
            ))
            mockEvents.append(CalendarEvent(
                title: "Design Review",
                startDate: calendar.date(byAdding: .hour, value: 10, to: calendar.startOfDay(for: day))!,
                endDate: calendar.date(byAdding: .hour, value: 11, to: calendar.startOfDay(for: day))!,
                location: "Design Studio",
                source: .system
            ))
            mockEvents.append(CalendarEvent(
                title: "Lunch & Learn",
                startDate: calendar.date(byAdding: .hour, value: 13, to: calendar.startOfDay(for: day))!,
                endDate: calendar.date(byAdding: .hour, value: 14, to: calendar.startOfDay(for: day))!,
                location: "Cafeteria",
                source: .user
            ))
            mockEvents.append(CalendarEvent(
                title: "Code Review",
                startDate: calendar.date(byAdding: .hour, value: 16, to: calendar.startOfDay(for: day))!,
                endDate: calendar.date(byAdding: .hour, value: 17, to: calendar.startOfDay(for: day))!,
                source: .system
            ))
        }
        
        // 19 de Noviembre - Miércoles (3 eventos)
        dateComponents.day = 19
        if let day = calendar.date(from: dateComponents) {
            mockEvents.append(CalendarEvent(
                title: "Gym Session",
                startDate: calendar.date(byAdding: .hour, value: 6, to: calendar.startOfDay(for: day))! + 1800,
                endDate: calendar.date(byAdding: .hour, value: 8, to: calendar.startOfDay(for: day))!,
                location: "Fitness Center",
                notes: "Leg day",
                source: .healthKit
            ))
            mockEvents.append(CalendarEvent(
                title: "All Hands Meeting",
                startDate: calendar.date(byAdding: .hour, value: 14, to: calendar.startOfDay(for: day))!,
                endDate: calendar.date(byAdding: .hour, value: 15, to: calendar.startOfDay(for: day))!,
                location: "Main Hall",
                source: .system
            ))
            mockEvents.append(CalendarEvent(
                title: "Break Time",
                startDate: calendar.date(byAdding: .hour, value: 17, to: calendar.startOfDay(for: day))!,
                endDate: calendar.date(byAdding: .hour, value: 17, to: calendar.startOfDay(for: day))! + 900,
                notes: "AI suggested rest",
                source: .ai
            ))
        }
        
        // 20 de Noviembre - Jueves (2 eventos)
        dateComponents.day = 20
        if let day = calendar.date(from: dateComponents) {
            mockEvents.append(CalendarEvent(
                title: "Sprint Planning",
                startDate: calendar.date(byAdding: .hour, value: 9, to: calendar.startOfDay(for: day))!,
                endDate: calendar.date(byAdding: .hour, value: 11, to: calendar.startOfDay(for: day))!,
                location: "Conference Room C",
                source: .system
            ))
            mockEvents.append(CalendarEvent(
                title: "Happy Hour",
                startDate: calendar.date(byAdding: .hour, value: 18, to: calendar.startOfDay(for: day))!,
                endDate: calendar.date(byAdding: .hour, value: 20, to: calendar.startOfDay(for: day))!,
                location: "Local Bar",
                source: .user
            ))
        }
        
        let today = Date()
        todayEvents = mockEvents.filter { calendar.isDate($0.startDate, inSameDayAs: today) }
        monthEvents = mockEvents
        organizeEventsForDays()
    }
    
    private func loadEventsForDate(_ date: Date) {
        let calendar = Calendar.current
        todayEvents = monthEvents.filter { event in
            calendar.isDate(event.startDate, inSameDayAs: date)
        }
        print("📅 Cargados \(todayEvents.count) eventos para \(date)")
    }
    
    private func loadEventsForMonth(_ month: Date) {
        loadEventsForDate(selectedDate)
        print("📅 Eventos del mes cargados")
    }
    
    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true
        isLoading = false
        print("❌ Calendar Error: \(error.localizedDescription)")
    }
}

// MARK: - Supporting Types

/// Modos de vista del calendario
enum CalendarViewMode: String, CaseIterable {
    case month = "Month"
    case week = "Week"
    case day = "Day"
    
    var systemImage: String {
        switch self {
        case .month: return "calendar"
        case .week: return "calendar.day.timeline.leading"
        case .day: return "calendar.day.timeline.right"
        }
    }
}

// MARK: - TODO: Backend Implementation Notes

/*
 BACKEND PENDIENTE - Implementaciones necesarias:
 
 1. CalendarManager.swift
    - Integración con EventKit para eventos del sistema
    - CRUD de eventos personalizados
    - Sincronización con calendarios externos
    - Métodos: getEvents(), saveEvent(), deleteEvent(), updateEvent()
 
 2. EventKit Integration
    - Solicitar permisos de calendario
    - Leer eventos existentes del sistema
    - Crear/editar eventos en calendarios del usuario
    - Manejar diferentes tipos de calendario (personal, trabajo, etc.)
 
 3. HealthKit Integration
    - Generar eventos automáticos desde datos de salud
    - Workouts → Calendar events
    - Sleep sessions → Calendar blocks
    - Medication reminders → Calendar alerts
 
 4. AI Event Suggestions
    - Analizar patrones de Body Battery
    - Sugerir breaks y focus time
    - Recomendar workout times
    - Integrar con VapiChat para scheduling
 
 5. CalendarStore.swift
    - Persistencia local de eventos personalizados
    - Cache de eventos del sistema
    - Configuración de preferencias de calendario
    - Backup y restore de datos
 
 6. Permisos en Info.plist:
    - NSCalendarsUsageDescription
    - Descripción: "Para mostrar tus eventos y ayudarte a planificar tu día"
 
 7. Notificaciones de Eventos:
    - Recordatorios personalizados
    - Integración con focus modes
    - Alertas de Body Battery para eventos importantes
 
 8. Integración con Morning Briefing:
    - Eventos del día en DailyBriefingCard
    - Análisis de carga de trabajo
    - Recomendaciones de energía para eventos
 */
