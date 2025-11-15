import Foundation
import SwiftUI

// MARK: - Calendar Event Model

/// Modelo de evento de calendario
struct CalendarEvent: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var startDate: Date
    var endDate: Date
    var isAllDay: Bool
    var location: String?
    var notes: String?
    var source: EventSource
    
    // MARK: - Computed Properties
    
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
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: startDate)
    }
    
    // MARK: - Initialization
    
    init(
        id: UUID = UUID(),
        title: String,
        startDate: Date,
        endDate: Date,
        isAllDay: Bool = false,
        location: String? = nil,
        notes: String? = nil,
        source: EventSource = .user
    ) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.isAllDay = isAllDay
        self.location = location
        self.notes = notes
        self.source = source
    }
}

// MARK: - Event Source

/// Fuente del evento
enum EventSource: String, Codable, CaseIterable {
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
    
    var icon: String {
        switch self {
        case .system: return "calendar"
        case .user: return "person.fill"
        case .healthKit: return "heart.fill"
        case .ai: return "sparkles"
        }
    }
}

// MARK: - Event Priority

/// Prioridad del evento (para futuras features)
enum EventPriority: String, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    
    var color: Color {
        switch self {
        case .low: return .gray
        case .medium: return .orange
        case .high: return .red
        }
    }
}
