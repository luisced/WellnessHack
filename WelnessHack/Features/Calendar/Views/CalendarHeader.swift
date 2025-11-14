import SwiftUI

/// Header del calendario que muestra los días de la semana
struct CalendarHeader: View {
    let weekDays: [Date]
    let selectedDate: Date
    let onDateSelected: (Date) -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        HStack(spacing: 0) {
            // Espacio para la columna de horas
            Rectangle()
                .fill(Color.clear)
                .frame(width: 60)
            
            // Días de la semana
            ForEach(weekDays, id: \.self) { day in
                CalendarDayHeader(
                    date: day,
                    isSelected: calendar.isDate(day, inSameDayAs: selectedDate),
                    onTap: { onDateSelected(day) }
                )
            }
        }
        .background(
            // Efecto cristal (glassmorphism)
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(
                    Rectangle()
                        .fill(Color.calendarWhite.opacity(0.1))
                )
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
        )
    }
}

/// Componente individual para cada día en el header
struct CalendarDayHeader: View {
    let date: Date
    let isSelected: Bool
    let onTap: () -> Void
    
    private let calendar = Calendar.current
    
    var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).uppercased()
    }
    
    var isToday: Bool {
        calendar.isDateInToday(date)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            // Nombre del día (LUN, MAR, etc.)
            Text(dayName)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(textColor.opacity(0.7))
            
            // Número del día
            Text(dayNumber)
                .font(.title3)
                .fontWeight(isSelected || isToday ? .bold : .medium)
                .foregroundColor(textColor)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(backgroundCircleColor)
                        .scaleEffect(isSelected ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.2), value: isSelected)
                )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .background(
            Rectangle()
                .fill(isSelected ? Color.calendarMint.opacity(0.1) : Color.clear)
                .animation(.easeInOut(duration: 0.2), value: isSelected)
        )
    }
    
    private var textColor: Color {
        if isSelected {
            return .white
        } else if isToday {
            return Color.calendarDarkBlue
        } else {
            return Color.calendarDarkBlue.opacity(0.8)
        }
    }
    
    private var backgroundCircleColor: Color {
        if isSelected {
            return Color.calendarDarkBlue
        } else {
            return Color.clear
        }
    }
}

/// Navegación simple (anterior/siguiente) sin texto de rango
struct CalendarSimpleNavigation: View {
    let onPrevious: () -> Void
    let onNext: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onPrevious) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(Color.calendarDarkBlue)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Circle()
                                    .fill(Color.calendarWhite.opacity(0.2))
                            )
                    )
            }
            
            Spacer()
            
            Button(action: onNext) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(Color.calendarDarkBlue)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Circle()
                                    .fill(Color.calendarWhite.opacity(0.2))
                            )
                    )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(
                    Rectangle()
                        .fill(Color.calendarWhite.opacity(0.1))
                )
        )
    }
}

// MARK: - Preview

#Preview("Calendar Header") {
    let calendar = Calendar.current
    let today = Date()
    let threeDays = (-1...1).compactMap { offset in
        calendar.date(byAdding: .day, value: offset, to: today)
    }
    
    VStack(spacing: 0) {
        CalendarSimpleNavigation(
            onPrevious: { print("Previous 3 days") },
            onNext: { print("Next 3 days") }
        )
        
        CalendarHeader(
            weekDays: threeDays,
            selectedDate: today,
            onDateSelected: { date in
                print("Selected date: \(date)")
            }
        )
    }
    .background(
        LinearGradient(
            gradient: Gradient(colors: [
                Color.calendarDarkBlue,
                Color.calendarLightBlue,
                Color.calendarMint,
                Color.calendarWhite
            ]),
            startPoint: .bottomLeading,
            endPoint: .topTrailing
        )
    )
}

#Preview("Day Header States") {
    let calendar = Calendar.current
    let today = Date()
    let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
    let dayAfter = calendar.date(byAdding: .day, value: 2, to: today)!
    
    HStack(spacing: 20) {
        CalendarDayHeader(
            date: today,
            isSelected: false,
            onTap: { print("Today tapped") }
        )
        .frame(width: 80)
        
        CalendarDayHeader(
            date: tomorrow,
            isSelected: true,
            onTap: { print("Tomorrow tapped") }
        )
        .frame(width: 80)
        
        CalendarDayHeader(
            date: dayAfter,
            isSelected: false,
            onTap: { print("Day after tapped") }
        )
        .frame(width: 80)
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}
