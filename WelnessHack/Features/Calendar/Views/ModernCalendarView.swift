import SwiftUI

/// Vista de calendario moderna con lista de eventos para un solo día
struct ModernCalendarView: View {
    @ObservedObject var viewModel: CalendarViewModel
    
    // Eventos del día seleccionado, ordenados cronológicamente
    private var sortedDayEvents: [CalendarEvent] {
        let selectedDayStart = Calendar.current.startOfDay(for: viewModel.selectedDate)
        let eventsForDay = viewModel.monthEvents.filter { event in
            Calendar.current.isDate(event.startDate, inSameDayAs: selectedDayStart)
        }
        return eventsForDay.sorted { $0.startDate < $1.startDate }
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Header del día seleccionado (con swipe navigation)
                SingleDayHeader(viewModel: viewModel)
                
                // Lista vertical de eventos ordenados cronológicamente
                EventsList(events: sortedDayEvents)
            }
        }
    }
}

/// Header principal con selector de mes expandible
struct ModernCalendarHeader: View {
    @ObservedObject var viewModel: CalendarViewModel
    @State private var showMonthPicker = false
    
    private var monthText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: viewModel.centerDate)
    }
    
    private var todayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: Date())
    }
    
    var body: some View {
        HStack {
            // Selector de mes expandible
            Button(action: { showMonthPicker.toggle() }) {
                HStack(spacing: 8) {
                    Text(monthText)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.calendarDarkBlue)
                    
                    Image(systemName: showMonthPicker ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(Color.calendarDarkBlue.opacity(0.7))
                }
            }
            
            Spacer()
            
            // Today button - Click to jump to today
            Button(action: {
                // Navegar al día de hoy
                viewModel.centerDate = Date()
                viewModel.selectedDate = Date()
                viewModel.setupCurrentDays()
                viewModel.organizeEventsForDays()
            }) {
                Text(todayNumber)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(Color.calendarDarkBlue.opacity(0.8))
                    )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            // Mismo estilo que el tab bar inferior
            Rectangle()
                .fill(Color.calendarMint.opacity(0.3))
                .background(
                    Rectangle()
                        .fill(.thinMaterial)
                        .opacity(0.5)
                )
        )
        .sheet(isPresented: $showMonthPicker) {
            MonthYearPicker(
                selectedDate: Binding(
                    get: { viewModel.centerDate },
                    set: { newDate in
                        viewModel.centerDate = newDate
                        viewModel.setupCurrentDays()
                        viewModel.organizeEventsForDays()
                    }
                ),
                isPresented: $showMonthPicker
            )
        }
    }
}

/// Header con el día seleccionado (navegación por swipe)
struct SingleDayHeader: View {
    @ObservedObject var viewModel: CalendarViewModel
    @State private var dragOffset: CGFloat = 0
    
    private let calendar = Calendar.current
    
    private var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE" // Día completo: Monday, Tuesday, etc.
        return formatter.string(from: viewModel.selectedDate)
    }
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: viewModel.selectedDate)
    }
    
    private var isToday: Bool {
        calendar.isDateInToday(viewModel.selectedDate)
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Navegación: Día anterior (color tenue)
            Button(action: {
                if let previousDay = calendar.date(byAdding: .day, value: -1, to: viewModel.selectedDate) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        viewModel.selectDate(previousDay)
                    }
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundColor(Color.calendarDarkBlue.opacity(0.3))
                    .frame(width: 44, height: 44)
            }
            
            Spacer()
            
            // Día seleccionado
            VStack(spacing: 4) {
                Text(dayName)
                    .font(.headline)
                    .foregroundColor(Color.calendarDarkBlue)
                
                Text(dayNumber)
                    .font(.title)
                    .fontWeight(isToday ? .bold : .semibold)
                    .foregroundColor(Color.calendarDarkBlue)
            }
            
            Spacer()
            
            // Navegación: Día siguiente (color tenue)
            Button(action: {
                if let nextDay = calendar.date(byAdding: .day, value: 1, to: viewModel.selectedDate) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        viewModel.selectDate(nextDay)
                    }
                }
            }) {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundColor(Color.calendarDarkBlue.opacity(0.3))
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.vertical, 16)
        .background(
            Rectangle()
                .fill(Color.calendarMint.opacity(0.3))
                .background(
                    Rectangle()
                        .fill(.thinMaterial)
                        .opacity(0.5)
                )
        )
        .overlay(
            Rectangle()
                .fill(Color.calendarDarkBlue.opacity(0.2))
                .frame(height: 1),
            alignment: .bottom
        )
        .offset(x: dragOffset)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    dragOffset = gesture.translation.width
                }
                .onEnded { gesture in
                    let threshold: CGFloat = 50
                    
                    if gesture.translation.width > threshold {
                        // Swipe derecha -> día anterior
                        if let previousDay = calendar.date(byAdding: .day, value: -1, to: viewModel.selectedDate) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                viewModel.selectDate(previousDay)
                            }
                        }
                    } else if gesture.translation.width < -threshold {
                        // Swipe izquierda -> día siguiente
                        if let nextDay = calendar.date(byAdding: .day, value: 1, to: viewModel.selectedDate) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                viewModel.selectDate(nextDay)
                            }
                        }
                    }
                    
                    // Reset offset
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        dragOffset = 0
                    }
                }
        )
    }
}

/// Lista vertical de eventos ordenados cronológicamente
struct EventsList: View {
    let events: [CalendarEvent]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            if events.isEmpty {
                // Mensaje cuando no hay eventos
                VStack(spacing: 16) {
                    Spacer()
                        .frame(height: 60)
                    
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 60))
                        .foregroundColor(Color.calendarDarkBlue.opacity(0.3))
                    
                    Text("No events scheduled")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(Color.calendarDarkBlue.opacity(0.7))
                    
                    Text("Enjoy your free day")
                        .font(.callout)
                        .foregroundColor(Color.calendarDarkBlue.opacity(0.5))
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                // Lista de eventos
                LazyVStack(spacing: 12) {
                    ForEach(events) { event in
                        EventListCard(event: event)
                            .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical, 16)
            }
        }
    }
}

/// Tarjeta de evento en la lista
struct EventListCard: View {
    let event: CalendarEvent
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: event.startDate)
    }
    
    private var durationString: String {
        let hours = Int(event.duration / 3600)
        let minutes = Int((event.duration.truncatingRemainder(dividingBy: 3600)) / 60)
        
        if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Hora del evento
            VStack(alignment: .trailing, spacing: 4) {
                Text(timeString)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.calendarDarkBlue)
                
                Text(durationString)
                    .font(.caption)
                    .foregroundColor(Color.calendarDarkBlue.opacity(0.6))
            }
            .frame(width: 70, alignment: .trailing)
            
            // Barra lateral de color según el tipo de evento
            Rectangle()
                .fill(event.source.color)
                .frame(width: 4)
                .cornerRadius(2)
            
            // Contenido del evento
            VStack(alignment: .leading, spacing: 6) {
                Text(event.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(Color.calendarDarkBlue)
                
                if let location = event.location {
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.caption)
                        Text(location)
                            .font(.caption)
                    }
                    .foregroundColor(Color.calendarDarkBlue.opacity(0.6))
                }
                
                if let notes = event.notes {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(Color.calendarDarkBlue.opacity(0.5))
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.calendarDarkBlue.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}


/// Selector de mes y año
struct MonthYearPicker: View {
    @Binding var selectedDate: Date
    @Binding var isPresented: Bool
    
    private let calendar = Calendar.current
    private let months = Calendar.current.monthSymbols
    private let years = Array(2020...2030)
    
    private var selectedMonth: Int {
        calendar.component(.month, from: selectedDate) - 1
    }
    
    private var selectedYear: Int {
        calendar.component(.year, from: selectedDate)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Select Month & Year")
                    .font(.headline)
                    .foregroundColor(Color.calendarDarkBlue)
                
                HStack(spacing: 20) {
                    // Month picker
                    VStack {
                        Text("Month")
                            .font(.caption)
                            .foregroundColor(Color.calendarDarkBlue.opacity(0.7))
                        
                        Picker("Month", selection: Binding(
                            get: { selectedMonth },
                            set: { newMonth in
                                updateDate(month: newMonth + 1, year: selectedYear)
                            }
                        )) {
                            ForEach(0..<months.count, id: \.self) { index in
                                Text(months[index]).tag(index)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(height: 150)
                    }
                    
                    // Year picker
                    VStack {
                        Text("Year")
                            .font(.caption)
                            .foregroundColor(Color.calendarDarkBlue.opacity(0.7))
                        
                        Picker("Year", selection: Binding(
                            get: { selectedYear },
                            set: { newYear in
                                updateDate(month: selectedMonth + 1, year: newYear)
                            }
                        )) {
                            ForEach(years, id: \.self) { year in
                                Text("\(year)").tag(year)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(height: 150)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(Color.calendarDarkBlue)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                    .foregroundColor(Color.calendarDarkBlue)
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.height(400)])
        .presentationDragIndicator(.visible)
    }
    
    private func updateDate(month: Int, year: Int) {
        var components = calendar.dateComponents([.day, .month, .year], from: selectedDate)
        components.month = month
        components.year = year
        
        if let newDate = calendar.date(from: components) {
            selectedDate = newDate
        }
    }
}

// MARK: - Preview

#Preview("Modern Calendar View") {
    @Previewable @StateObject var viewModel = CalendarViewModel()
    ModernCalendarView(viewModel: viewModel)
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

#Preview("Calendar with Events") {
    @Previewable @StateObject var viewModel = CalendarViewModel()
    ModernCalendarView(viewModel: viewModel)
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
