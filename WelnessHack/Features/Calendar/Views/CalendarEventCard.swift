import SwiftUI

/// Tarjeta uniforme para mostrar eventos en el calendario
struct CalendarEventCard: View {
    let event: CalendarEvent
    let cardHeight: CGFloat
    
    init(event: CalendarEvent, cardHeight: CGFloat = 60) {
        self.event = event
        self.cardHeight = cardHeight
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(event.source.color.opacity(0.8))
            .frame(height: cardHeight)
            .overlay(
                VStack(alignment: .leading, spacing: 2) {
                    // Título del evento
                    Text(event.title)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    // Hora del evento
                    Text(event.formattedTime)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(1)
                    
                    // Ubicación (si existe)
                    if let location = event.location, !location.isEmpty {
                        Text(location)
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                            .lineLimit(1)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            )
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

/// Vista de slot de tiempo que puede contener múltiples eventos
struct CalendarTimeSlot: View {
    let hour: Int
    let day: Date
    let events: [CalendarEvent]
    let slotHeight: CGFloat = 60
    
    var body: some View {
        VStack(spacing: 2) {
            ForEach(events) { event in
                CalendarEventCard(
                    event: event,
                    cardHeight: calculateEventHeight(for: event)
                )
                .onTapGesture {
                    // TODO: BACKEND - Manejar tap en evento
                    print("📅 Tapped event: \(event.title)")
                }
            }
            
            Spacer()
        }
        .frame(height: slotHeight)
        .frame(maxWidth: .infinity)
        .background(
            Rectangle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
        )
        .onTapGesture {
            // TODO: BACKEND - Crear nuevo evento en este slot
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            let timeString = formatter.string(from: Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: day) ?? day)
            print("📅 Tapped empty slot: \(timeString)")
        }
    }
    
    /// Calcula la altura del evento basado en su duración
    private func calculateEventHeight(for event: CalendarEvent) -> CGFloat {
        let durationInHours = event.duration / 3600 // Convertir segundos a horas
        let minHeight: CGFloat = 40
        let maxHeight: CGFloat = slotHeight - 4
        
        // Eventos de menos de 1 hora usan altura mínima
        if durationInHours < 1 {
            return minHeight
        }
        
        // Eventos más largos escalan proporcionalmente
        let calculatedHeight = CGFloat(durationInHours) * 30 // 30pt por hora
        return min(calculatedHeight, maxHeight)
    }
}

// MARK: - Preview

#Preview("Event Card") {
    VStack(spacing: 10) {
        CalendarEventCard(
            event: CalendarEvent(
                id: UUID(),
                title: "Team Meeting",
                startDate: Date(),
                endDate: Date().addingTimeInterval(3600),
                isAllDay: false,
                location: "Conference Room A",
                notes: "Weekly sync",
                source: .system
            )
        )
        
        CalendarEventCard(
            event: CalendarEvent(
                id: UUID(),
                title: "Morning Workout",
                startDate: Date(),
                endDate: Date().addingTimeInterval(1800),
                isAllDay: false,
                location: "Gym",
                notes: nil,
                source: .healthKit
            ),
            cardHeight: 40
        )
        
        CalendarEventCard(
            event: CalendarEvent(
                id: UUID(),
                title: "Focus Time - Deep Work Session",
                startDate: Date(),
                endDate: Date().addingTimeInterval(7200),
                isAllDay: false,
                location: nil,
                notes: "No interruptions",
                source: .ai
            )
        )
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}

#Preview("Time Slot") {
    CalendarTimeSlot(
        hour: 10,
        day: Date(),
        events: [
            CalendarEvent(
                id: UUID(),
                title: "Team Meeting",
                startDate: Date(),
                endDate: Date().addingTimeInterval(3600),
                isAllDay: false,
                location: "Conference Room A",
                notes: "Weekly sync",
                source: .system
            ),
            CalendarEvent(
                id: UUID(),
                title: "Coffee Break",
                startDate: Date().addingTimeInterval(1800),
                endDate: Date().addingTimeInterval(2700),
                isAllDay: false,
                location: nil,
                notes: nil,
                source: .user
            )
        ]
    )
    .frame(width: 120)
    .padding()
}
