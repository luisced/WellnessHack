import SwiftUI

/// Columna izquierda con las etiquetas de horas del calendario
struct CalendarHourLabels: View {
    let hours: [Int]
    let hourHeight: CGFloat
    
    init(startHour: Int = 0, endHour: Int = 23, hourHeight: CGFloat = 60) {
        self.hours = Array(startHour...endHour)
        self.hourHeight = hourHeight
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(hours, id: \.self) { hour in
                CalendarHourLabel(
                    hour: hour,
                    height: hourHeight
                )
            }
        }
    }
}

/// Etiqueta individual para cada hora
struct CalendarHourLabel: View {
    let hour: Int
    let height: CGFloat
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        let calendar = Calendar.current
        let date = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: Date()) ?? Date()
        
        return formatter.string(from: date)
    }
    
    private var hourString: String {
        if hour == 0 {
            return "12 AM"
        } else if hour < 12 {
            return "\(hour) AM"
        } else if hour == 12 {
            return "12 PM"
        } else {
            return "\(hour - 12) PM"
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(hourString)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(Color.calendarDarkBlue.opacity(0.7))
                    .frame(width: 50, alignment: .trailing)
                
                Spacer()
            }
            .padding(.horizontal, 8)
            
            Spacer()
        }
        .frame(width: 60, height: height)
        .background(
            VStack {
                Spacer()
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 0.5)
            }
        )
    }
}

/// Vista de líneas de tiempo para mostrar divisiones cada 30 minutos
struct CalendarTimeGrid: View {
    let hours: [Int]
    let hourHeight: CGFloat
    let showHalfHours: Bool
    
    init(startHour: Int = 0, endHour: Int = 23, hourHeight: CGFloat = 60, showHalfHours: Bool = true) {
        self.hours = Array(startHour...endHour)
        self.hourHeight = hourHeight
        self.showHalfHours = showHalfHours
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(hours, id: \.self) { hour in
                VStack(spacing: 0) {
                    // Línea de la hora completa
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 1)
                    
                    if showHalfHours && hour < hours.last ?? 23 {
                        Spacer()
                        
                        // Línea de media hora (más sutil)
                        Rectangle()
                            .fill(Color.gray.opacity(0.15))
                            .frame(height: 0.5)
                        
                        Spacer()
                    } else {
                        Spacer()
                    }
                }
                .frame(height: hourHeight)
            }
        }
    }
}

/// Indicador de hora actual (línea roja que se mueve)
struct CalendarCurrentTimeIndicator: View {
    let currentHour: Int
    let currentMinute: Int
    let hourHeight: CGFloat
    
    private var offsetFromTop: CGFloat {
        let totalMinutes = currentHour * 60 + currentMinute
        let pixelsPerMinute = hourHeight / 60
        return CGFloat(totalMinutes) * pixelsPerMinute
    }
    
    var body: some View {
        HStack {
            // Círculo indicador
            Circle()
                .fill(Color.red)
                .frame(width: 8, height: 8)
                .offset(x: -4)
            
            // Línea horizontal
            Rectangle()
                .fill(Color.red)
                .frame(height: 2)
            
            Spacer()
        }
        .offset(y: offsetFromTop)
        .zIndex(100) // Asegurar que esté encima de otros elementos
    }
}

// MARK: - Preview

#Preview("Hour Labels") {
    CalendarHourLabels(
        startHour: 8,
        endHour: 18,
        hourHeight: 60
    )
    .frame(width: 60)
    .background(Color.gray.opacity(0.1))
}

#Preview("Time Grid") {
    HStack(spacing: 0) {
        CalendarHourLabels(
            startHour: 9,
            endHour: 17,
            hourHeight: 80
        )
        
        CalendarTimeGrid(
            startHour: 9,
            endHour: 17,
            hourHeight: 80,
            showHalfHours: true
        )
        .frame(width: 200)
    }
    .background(Color.gray.opacity(0.1))
}

#Preview("Current Time Indicator") {
    let currentHour = Calendar.current.component(.hour, from: Date())
    let currentMinute = Calendar.current.component(.minute, from: Date())
    
    ZStack {
        CalendarTimeGrid(
            startHour: 8,
            endHour: 18,
            hourHeight: 60
        )
        .frame(width: 300)
        
        CalendarCurrentTimeIndicator(
            currentHour: currentHour,
            currentMinute: currentMinute,
            hourHeight: 60
        )
        .frame(width: 300)
    }
    .background(Color.gray.opacity(0.1))
}

#Preview("Full Hour Column") {
    ScrollView {
        HStack(spacing: 0) {
            CalendarHourLabels(hourHeight: 60)
            
            ZStack {
                CalendarTimeGrid(hourHeight: 60)
                
                CalendarCurrentTimeIndicator(
                    currentHour: 14,
                    currentMinute: 30,
                    hourHeight: 60
                )
            }
            .frame(width: 250)
        }
    }
    .frame(height: 400)
    .background(Color.gray.opacity(0.1))
}
