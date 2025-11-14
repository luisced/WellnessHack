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
    
    // TODO: BACKEND - Agregar EventKit manager cuando se implemente
    // private var eventStore: EKEventStore?
    
    // TODO: BACKEND - Agregar CalendarManager
    // private var calendarManager: CalendarManager?
    
    // TODO: BACKEND - Agregar integración con HealthKit para eventos de salud
    // private var healthKitManager: HealthKitManager?
    
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
    
    /// Agrega un nuevo evento
    func addEvent(title: String, date: Date, duration: TimeInterval = 3600) async {
        // TODO: BACKEND - Implementar creación de eventos
        /*
        do {
            let event = CalendarEvent(
                id: UUID(),
                title: title,
                startDate: date,
                endDate: date.addingTimeInterval(duration),
                isAllDay: false,
                location: nil,
                notes: nil,
                source: .user
            )
            
            try await calendarManager?.saveEvent(event)
            await loadEventsForDate(selectedDate)
            
        } catch {
            handleError(error)
        }
        */
        
        // MOCK: Simular creación de evento
        let mockEvent = CalendarEvent(
            id: UUID(),
            title: title,
            startDate: date,
            endDate: date.addingTimeInterval(duration),
            isAllDay: false,
            location: nil,
            notes: nil,
            source: .user
        )
        
        todayEvents.append(mockEvent)
        monthEvents.append(mockEvent)
        
        print("📅 [MOCK] Evento creado: \(title)")
    }
    
    /// Elimina un evento
    func deleteEvent(_ event: CalendarEvent) async {
        // TODO: BACKEND - Implementar eliminación de eventos
        /*
        do {
            try await calendarManager?.deleteEvent(event)
            await loadEventsForDate(selectedDate)
        } catch {
            handleError(error)
        }
        */
        
        // MOCK: Simular eliminación
        todayEvents.removeAll { $0.id == event.id }
        monthEvents.removeAll { $0.id == event.id }
        
        print("📅 [MOCK] Evento eliminado: \(event.title)")
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
        // MOCK: Eventos de ejemplo distribuidos en la semana para testing UI
        let calendar = Calendar.current
        let today = Date()
        
        var mockEvents: [CalendarEvent] = []
        
        // Eventos para diferentes días de la semana
        for dayOffset in -2...4 { // Semana completa
            guard let day = calendar.date(byAdding: .day, value: dayOffset, to: today) else { continue }
            
            // Eventos matutinos
            if dayOffset != 0 { // No en domingo
                mockEvents.append(CalendarEvent(
                    id: UUID(),
                    title: "Morning Workout",
                    startDate: calendar.date(byAdding: .hour, value: 7, to: calendar.startOfDay(for: day))!,
                    endDate: calendar.date(byAdding: .hour, value: 8, to: calendar.startOfDay(for: day))!,
                    isAllDay: false,
                    location: "Gym",
                    notes: "Cardio + weights",
                    source: .healthKit
                ))
            }
            
            // Eventos de trabajo (lunes a viernes)
            if dayOffset >= -1 && dayOffset <= 3 {
                mockEvents.append(CalendarEvent(
                    id: UUID(),
                    title: "Team Meeting",
                    startDate: calendar.date(byAdding: .hour, value: 10, to: calendar.startOfDay(for: day))!,
                    endDate: calendar.date(byAdding: .hour, value: 11, to: calendar.startOfDay(for: day))!,
                    isAllDay: false,
                    location: "Conference Room A",
                    notes: "Weekly sync",
                    source: .system
                ))
                
                mockEvents.append(CalendarEvent(
                    id: UUID(),
                    title: "Focus Time",
                    startDate: calendar.date(byAdding: .hour, value: 14, to: calendar.startOfDay(for: day))!,
                    endDate: calendar.date(byAdding: .hour, value: 16, to: calendar.startOfDay(for: day))!,
                    isAllDay: false,
                    location: nil,
                    notes: "Deep work session",
                    source: .ai
                ))
            }
            
            // Eventos de almuerzo
            mockEvents.append(CalendarEvent(
                id: UUID(),
                title: "Lunch Break",
                startDate: calendar.date(byAdding: .hour, value: 13, to: calendar.startOfDay(for: day))!,
                endDate: calendar.date(byAdding: .hour, value: 14, to: calendar.startOfDay(for: day))!,
                isAllDay: false,
                location: dayOffset == 0 ? "Restaurant" : nil,
                notes: "Mindful eating",
                source: .user
            ))
            
            // Eventos de fin de semana
            if dayOffset == -2 || dayOffset == 4 {
                mockEvents.append(CalendarEvent(
                    id: UUID(),
                    title: "Family Time",
                    startDate: calendar.date(byAdding: .hour, value: 16, to: calendar.startOfDay(for: day))!,
                    endDate: calendar.date(byAdding: .hour, value: 18, to: calendar.startOfDay(for: day))!,
                    isAllDay: false,
                    location: "Home",
                    notes: "Quality time",
                    source: .user
                ))
            }
        }
        
        todayEvents = mockEvents.filter { calendar.isDate($0.startDate, inSameDayAs: today) }
        monthEvents = mockEvents
        organizeEventsForDays()
    }
    
    private func loadEventsForDate(_ date: Date) {
        // TODO: BACKEND - Cargar eventos reales para la fecha
        /*
        Task {
            do {
                isLoading = true
                let events = try await calendarManager?.getEvents(for: date) ?? []
                
                await MainActor.run {
                    todayEvents = events
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    handleError(error)
                    isLoading = false
                }
            }
        }
        */
        
        // MOCK: Filtrar eventos mock para la fecha seleccionada
        let calendar = Calendar.current
        todayEvents = monthEvents.filter { event in
            calendar.isDate(event.startDate, inSameDayAs: date)
        }
        
        print("📅 [MOCK] Cargados \(todayEvents.count) eventos para \(date)")
    }
    
    private func loadEventsForMonth(_ month: Date) {
        // TODO: BACKEND - Cargar eventos del mes
        /*
        Task {
            do {
                isLoading = true
                let events = try await calendarManager?.getEvents(for: month) ?? []
                
                await MainActor.run {
                    monthEvents = events
                    loadEventsForDate(selectedDate)
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    handleError(error)
                    isLoading = false
                }
            }
        }
        */
        
        // MOCK: Mantener eventos mock
        loadEventsForDate(selectedDate)
        print("📅 [MOCK] Eventos del mes cargados")
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

/// Modelo de evento de calendario
struct CalendarEvent: Identifiable, Codable {
    let id: UUID
    let title: String
    let startDate: Date
    let endDate: Date
    let isAllDay: Bool
    let location: String?
    let notes: String?
    let source: EventSource
    
    var duration: TimeInterval {
        endDate.timeIntervalSince(startDate)
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        if isAllDay {
            return "All Day"
        } else {
            return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
        }
    }
}

/// Fuente del evento
enum EventSource: String, Codable {
    case system = "system"     // Calendario del sistema
    case user = "user"         // Creado por el usuario
    case healthKit = "health"  // Generado desde HealthKit
    case ai = "ai"            // Sugerido por IA
    
    var color: Color {
        switch self {
        case .system: return Color.calendarLightBlue      // Azul suave
        case .user: return Color.calendarMint             // Verde menta
        case .healthKit: return Color.calendarLightBlue   // Azul suave
        case .ai: return Color.calendarMint               // Verde menta
        }
    }
    
    var displayName: String {
        switch self {
        case .system: return "System"
        case .user: return "Personal"
        case .healthKit: return "Health"
        case .ai: return "AI Suggested"
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
