import SwiftUI

/// Vista de calendario moderna con diseño minimalista y scroll bidireccional
struct ModernCalendarView: View {
    @ObservedObject var viewModel: CalendarViewModel
    
    private let hourHeight: CGFloat = 60
    private var visibleHours: [Int] {
        Array(viewModel.startHour...viewModel.endHour)
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Header principal con mes y navegación
                ModernCalendarHeader(viewModel: viewModel)
                
                // Días de la semana horizontal (con scroll horizontal)
                ModernDaysHeader(viewModel: viewModel)
                
                // Grid principal del calendario (con scroll bidireccional)
                ModernScrollableCalendarGrid(
                    viewModel: viewModel,
                    hours: visibleHours,
                    hourHeight: hourHeight
                )
            }
            
            // Botón flotante para añadir eventos (a la derecha)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    AddEventFloatingButton()
                }
                .padding(.bottom, 30)
                .padding(.trailing, 20)
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
            Rectangle()
                .fill(Color.calendarMint.opacity(0.3))
                .background(.ultraThinMaterial)
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

/// Header con días scrolleable horizontalmente
struct ModernDaysHeader: View {
    @ObservedObject var viewModel: CalendarViewModel
    
    private let calendar = Calendar.current
    
    // Generar más días para scroll horizontal (7 días hacia cada lado)
    private var extendedDays: [Date] {
        (-7...7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: viewModel.centerDate)
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Espacio para columna de horas
            Text("CST")
                .font(.caption)
                .foregroundColor(Color.calendarDarkBlue.opacity(0.7))
                .frame(width: 60, alignment: .leading)
                .padding(.leading, 8)
            
            // Días scrolleables horizontalmente
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(extendedDays, id: \.self) { day in
                        ModernDayHeaderItem(
                            date: day,
                            isSelected: calendar.isDate(day, inSameDayAs: viewModel.selectedDate),
                            onTap: { 
                                viewModel.selectDate(day)
                                viewModel.centerDate = day
                                viewModel.setupCurrentDays()
                                viewModel.organizeEventsForDays()
                            }
                        )
                        .frame(width: 80) // Ancho fijo para cada día
                    }
                }
                .padding(.horizontal, 10)
            }
        }
        .padding(.vertical, 12)
        .background(
            Rectangle()
                .fill(Color.calendarMint.opacity(0.3))
                .background(.ultraThinMaterial)
        )
        .overlay(
            Rectangle()
                .fill(Color.calendarDarkBlue.opacity(0.2))
                .frame(height: 1),
            alignment: .bottom
        )
    }
}

/// Item individual para cada día en el header
struct ModernDayHeaderItem: View {
    let date: Date
    let isSelected: Bool
    let onTap: () -> Void
    
    private let calendar = Calendar.current
    
    private var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private var isToday: Bool {
        calendar.isDateInToday(date)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(dayName)
                .font(.caption)
                .foregroundColor(Color.calendarDarkBlue.opacity(0.7))
            
            Text(dayNumber)
                .font(.title3)
                .fontWeight(isToday ? .bold : .medium)
                .foregroundColor(isToday ? .white : Color.calendarDarkBlue)
                .frame(width: 28, height: 28)
                .background(
                    Circle()
                        .fill(isToday ? Color.red : (isSelected ? Color.calendarMint.opacity(0.3) : Color.clear))
                )
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

/// Grid scrolleable bidireccional
struct ModernScrollableCalendarGrid: View {
    @ObservedObject var viewModel: CalendarViewModel
    let hours: [Int]
    let hourHeight: CGFloat
    
    var body: some View {
        ScrollView([.horizontal, .vertical], showsIndicators: false) {
            HStack(spacing: 0) {
                // Columna de horas (fija)
                ModernHourLabels(
                    hours: hours,
                    hourHeight: hourHeight
                )
                
                // Grid de días scrolleable
                HStack(spacing: 0) {
                    ForEach(viewModel.currentDisplayDays, id: \.self) { day in
                        ModernDayColumn(
                            day: day,
                            hours: hours,
                            hourHeight: hourHeight,
                            viewModel: viewModel
                        )
                        .frame(width: 100) // Ancho fijo para cada columna de día
                    }
                }
            }
        }
    }
}

/// Etiquetas de horas modernas
struct ModernHourLabels: View {
    let hours: [Int]
    let hourHeight: CGFloat
    
    var body: some View {
        VStack(spacing: 0) {
            // "All-day" row
            Text("All-day")
                .font(.caption)
                .foregroundColor(.white)
                .frame(width: 60, height: 40, alignment: .leading)
                .padding(.leading, 8)
            
            // Hour labels
            ForEach(hours, id: \.self) { hour in
                ModernHourLabel(
                    hour: hour,
                    height: hourHeight
                )
            }
        }
    }
}

/// Etiqueta individual de hora moderna
struct ModernHourLabel: View {
    let hour: Int
    let height: CGFloat
    
    private var hourString: String {
        if hour == 0 {
            return "12AM"
        } else if hour < 12 {
            return "\(hour)AM"
        } else if hour == 12 {
            return "12PM"
        } else {
            return "\(hour - 12)PM"
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(hourString)
                    .font(.caption)
                    .foregroundColor(.white)
                    .frame(width: 50, alignment: .leading)
                    .padding(.leading, 8)
                
                Spacer()
            }
            
            Spacer()
        }
        .frame(width: 60, height: height)
        .overlay(
            Rectangle()
                .fill(Color.calendarDarkBlue.opacity(0.1))
                .frame(height: 1),
            alignment: .bottom
        )
    }
}

/// Columna de día moderna
struct ModernDayColumn: View {
    let day: Date
    let hours: [Int]
    let hourHeight: CGFloat
    @ObservedObject var viewModel: CalendarViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // All-day section
            Rectangle()
                .fill(Color.clear)
                .frame(height: 40)
                .overlay(
                    Rectangle()
                        .fill(Color.calendarDarkBlue.opacity(0.1))
                        .frame(height: 1),
                    alignment: .bottom
                )
            
            // Hour slots
            ForEach(hours, id: \.self) { hour in
                ModernTimeSlot(
                    hour: hour,
                    day: day,
                    events: viewModel.getEvents(for: day, hour: hour)
                )
                .frame(height: hourHeight)
            }
        }
        .frame(maxWidth: .infinity)
        .overlay(
            Rectangle()
                .fill(Color.calendarDarkBlue.opacity(0.1))
                .frame(width: 1),
            alignment: .trailing
        )
    }
}

/// Slot de tiempo moderno
struct ModernTimeSlot: View {
    let hour: Int
    let day: Date
    let events: [CalendarEvent]
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.clear)
                .overlay(
                    Rectangle()
                        .fill(Color.calendarDarkBlue.opacity(0.1))
                        .frame(height: 1),
                    alignment: .bottom
                )
            
            // Events (si los hay)
            VStack(spacing: 2) {
                ForEach(events) { event in
                    ModernEventCard(event: event)
                }
                Spacer()
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            // TODO: BACKEND - Crear evento en este slot
            print("📅 Tapped slot: \(hour):00 on \(day)")
        }
    }
}

/// Tarjeta de evento moderna
struct ModernEventCard: View {
    let event: CalendarEvent
    
    var body: some View {
        HStack(spacing: 6) {
            Text(event.title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .lineLimit(1)
            
            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(event.source.color.opacity(0.3))
                .background(.ultraThinMaterial)
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

/// Botón flotante para añadir eventos
struct AddEventFloatingButton: View {
    @State private var showAddEvent = false
    
    var body: some View {
        Button(action: { showAddEvent = true }) {
            Image(systemName: "plus")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(Color.calendarDarkBlue)
                        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                )
        }
        .sheet(isPresented: $showAddEvent) {
            AddEventSheet(isPresented: $showAddEvent)
        }
    }
}

/// Sheet para añadir eventos (placeholder)
struct AddEventSheet: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Add New Event")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.calendarDarkBlue)
                
                Text("Event creation functionality will be implemented with backend integration.")
                    .font(.body)
                    .foregroundColor(Color.calendarDarkBlue.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding()
                
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
                    Button("Save") {
                        // TODO: BACKEND - Implementar creación de eventos
                        isPresented = false
                    }
                    .foregroundColor(Color.calendarDarkBlue)
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.height(300)])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Preview

#Preview("Modern Calendar View") {
    ModernCalendarView(viewModel: CalendarViewModel())
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

#Preview("Modern Calendar Header") {
    VStack {
        ModernCalendarHeader(viewModel: CalendarViewModel())
        ModernDaysHeader(viewModel: CalendarViewModel())
        Spacer()
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
