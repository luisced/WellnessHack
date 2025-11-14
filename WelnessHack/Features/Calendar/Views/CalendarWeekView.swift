import SwiftUI

/// Vista principal del calendario con 3 días y rango de horas ajustable
struct CalendarWeekView: View {
    @ObservedObject var viewModel: CalendarViewModel
    
    private let hourHeight: CGFloat = 60
    
    private var visibleHours: [Int] {
        Array(viewModel.startHour...viewModel.endHour)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Navegación simple sin texto de rango
            CalendarSimpleNavigation(
                onPrevious: viewModel.goToPreviousDays,
                onNext: viewModel.goToNextDays
            )
            
            // Control de rango de horas
            CalendarHourRangeCompact(
                startHour: Binding(
                    get: { viewModel.startHour },
                    set: { newStart in
                        viewModel.adjustHourRange(startHour: newStart, endHour: viewModel.endHour)
                    }
                ),
                endHour: Binding(
                    get: { viewModel.endHour },
                    set: { newEnd in
                        viewModel.adjustHourRange(startHour: viewModel.startHour, endHour: newEnd)
                    }
                )
            )
            .padding(.horizontal)
            .padding(.bottom, 8)
            
            // Header con días (3 días)
            CalendarHeader(
                weekDays: viewModel.currentDisplayDays,
                selectedDate: viewModel.selectedDate,
                onDateSelected: viewModel.selectDate
            )
            
            // Grid principal del calendario
            ScrollView {
                CalendarWeekGrid(
                    viewModel: viewModel,
                    hours: visibleHours,
                    hourHeight: hourHeight
                )
            }
            .scrollIndicators(.hidden)
        }
    }
}

/// Grid principal que combina horas y días
struct CalendarWeekGrid: View {
    @ObservedObject var viewModel: CalendarViewModel
    let hours: [Int]
    let hourHeight: CGFloat
    
    var body: some View {
        HStack(spacing: 0) {
            // Columna de horas
            CalendarHourLabels(
                startHour: hours.first ?? 0,
                endHour: hours.last ?? 23,
                hourHeight: hourHeight
            )
            
            // Grid de días y eventos
            ZStack {
                // Líneas de fondo del grid
                CalendarTimeGrid(
                    startHour: hours.first ?? 0,
                    endHour: hours.last ?? 23,
                    hourHeight: hourHeight,
                    showHalfHours: true
                )
                
                // Indicador de hora actual
                CalendarCurrentTimeIndicator(
                    currentHour: Calendar.current.component(.hour, from: Date()),
                    currentMinute: Calendar.current.component(.minute, from: Date()),
                    hourHeight: hourHeight
                )
                
                // Columnas de días con eventos (3 días)
                HStack(spacing: 0) {
                    ForEach(viewModel.currentDisplayDays, id: \.self) { day in
                        CalendarDayColumn(
                            day: day,
                            hours: hours,
                            hourHeight: hourHeight,
                            viewModel: viewModel
                        )
                    }
                }
            }
        }
    }
}

/// Columna individual para cada día
struct CalendarDayColumn: View {
    let day: Date
    let hours: [Int]
    let hourHeight: CGFloat
    @ObservedObject var viewModel: CalendarViewModel
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(hours, id: \.self) { hour in
                CalendarTimeSlot(
                    hour: hour,
                    day: day,
                    events: viewModel.getEvents(for: day, hour: hour)
                )
                .frame(height: hourHeight)
            }
        }
        .frame(maxWidth: .infinity)
        .background(
            // Líneas verticales separadoras
            VStack {
                Spacer()
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 1)
                    .frame(maxHeight: .infinity)
                Spacer()
            }
        )
    }
}

/// Vista compacta del calendario para usar en otras pantallas
struct CalendarCompactView: View {
    @ObservedObject var viewModel: CalendarViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            // Header compacto
            HStack {
                Text("This Week")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.calendarDarkBlue)
                
                Spacer()
                
                Button("View All") {
                    // TODO: FRONTEND - Navegar a CalendarScreen completo
                    print("📅 Navigate to full calendar")
                }
                .font(.caption)
                .foregroundColor(Color.calendarMint)
            }
            .padding(.horizontal)
            
            // Lista de eventos del día actual
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.todayEvents.prefix(3)) { event in
                        CalendarEventCard(event: event, cardHeight: 50)
                            .frame(width: 140)
                    }
                    
                    if viewModel.todayEvents.count > 3 {
                        Button("+\(viewModel.todayEvents.count - 3) more") {
                            // TODO: FRONTEND - Mostrar todos los eventos
                            print("📅 Show all events")
                        }
                        .font(.caption)
                        .foregroundColor(Color.calendarDarkBlue)
                        .frame(width: 80, height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.calendarMint, lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.calendarWhite.opacity(0.9))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - Preview

#Preview("Calendar Week View") {
    CalendarWeekView(viewModel: CalendarViewModel())
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

#Preview("Calendar Compact View") {
    VStack {
        CalendarCompactView(viewModel: CalendarViewModel())
            .padding()
        
        Spacer()
    }
    .background(Color.gray.opacity(0.1))
}

#Preview("Calendar Day Column") {
    let viewModel = CalendarViewModel()
    let today = Date()
    
    ScrollView {
        HStack(spacing: 0) {
            CalendarHourLabels(
                startHour: 8,
                endHour: 18,
                hourHeight: 60
            )
            
            CalendarDayColumn(
                day: today,
                hours: Array(8...18),
                hourHeight: 60,
                viewModel: viewModel
            )
            .frame(width: 120)
        }
    }
    .frame(height: 400)
    .background(Color.gray.opacity(0.1))
}
