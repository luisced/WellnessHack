import SwiftUI

/// Control deslizante para ajustar el rango de horas visible en el calendario
struct CalendarHourRangeSlider: View {
    @Binding var startHour: Int
    @Binding var endHour: Int
    
    private let minHour = 0
    private let maxHour = 23
    private let sliderHeight: CGFloat = 300
    
    @State private var isDraggingStart = false
    @State private var isDraggingEnd = false
    
    var body: some View {
        VStack(spacing: 8) {
            // Indicadores de hora
            HStack {
                Text(formatHour(startHour))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(Color.calendarDarkBlue)
                
                Spacer()
                
                Text(formatHour(endHour))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(Color.calendarDarkBlue)
            }
            .padding(.horizontal, 4)
            
            // Slider visual
            ZStack {
                // Fondo del slider
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 8, height: sliderHeight)
                
                // Rango seleccionado
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.calendarMint)
                    .frame(width: 8, height: selectedRangeHeight)
                    .offset(y: selectedRangeOffset)
                
                // Handle superior (hora final)
                Circle()
                    .fill(Color.calendarDarkBlue)
                    .frame(width: 20, height: 20)
                    .offset(y: endHourOffset)
                    .scaleEffect(isDraggingEnd ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.1), value: isDraggingEnd)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                isDraggingEnd = true
                                let newEndHour = hourFromOffset(value.location.y + endHourOffset)
                                endHour = max(startHour + 1, min(maxHour, newEndHour))
                            }
                            .onEnded { _ in
                                isDraggingEnd = false
                            }
                    )
                
                // Handle inferior (hora inicial)
                Circle()
                    .fill(Color.calendarDarkBlue)
                    .frame(width: 20, height: 20)
                    .offset(y: startHourOffset)
                    .scaleEffect(isDraggingStart ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.1), value: isDraggingStart)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                isDraggingStart = true
                                let newStartHour = hourFromOffset(value.location.y + startHourOffset)
                                startHour = max(minHour, min(endHour - 1, newStartHour))
                            }
                            .onEnded { _ in
                                isDraggingStart = false
                            }
                    )
            }
            .frame(height: sliderHeight)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Computed Properties
    
    private var startHourOffset: CGFloat {
        let ratio = CGFloat(startHour) / CGFloat(maxHour)
        return (ratio * sliderHeight) - (sliderHeight / 2)
    }
    
    private var endHourOffset: CGFloat {
        let ratio = CGFloat(endHour) / CGFloat(maxHour)
        return (ratio * sliderHeight) - (sliderHeight / 2)
    }
    
    private var selectedRangeHeight: CGFloat {
        let hourRange = CGFloat(endHour - startHour)
        return (hourRange / CGFloat(maxHour)) * sliderHeight
    }
    
    private var selectedRangeOffset: CGFloat {
        let centerHour = CGFloat(startHour + endHour) / 2
        let ratio = centerHour / CGFloat(maxHour)
        return (ratio * sliderHeight) - (sliderHeight / 2)
    }
    
    // MARK: - Helper Methods
    
    private func hourFromOffset(_ offset: CGFloat) -> Int {
        let adjustedOffset = offset + (sliderHeight / 2)
        let ratio = adjustedOffset / sliderHeight
        let hour = Int(ratio * CGFloat(maxHour))
        return max(minHour, min(maxHour, hour))
    }
    
    private func formatHour(_ hour: Int) -> String {
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
}

/// Control compacto para ajustar rango de horas
struct CalendarHourRangeCompact: View {
    @Binding var startHour: Int
    @Binding var endHour: Int
    @State private var showFullSlider = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Botón para mostrar/ocultar slider completo
            Button(action: { showFullSlider.toggle() }) {
                Image(systemName: "clock.arrow.2.circlepath")
                    .font(.title3)
                    .foregroundColor(Color.calendarDarkBlue)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Circle()
                                    .fill(Color.calendarWhite.opacity(0.2))
                            )
                    )
            }
            
            // Indicador de rango actual
            VStack(alignment: .leading, spacing: 2) {
                Text("Hours")
                    .font(.caption2)
                    .foregroundColor(Color.calendarDarkBlue.opacity(0.7))
                
                Text("\(formatHour(startHour)) - \(formatHour(endHour))")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(Color.calendarDarkBlue)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.calendarWhite.opacity(0.1))
                )
        )
        .sheet(isPresented: $showFullSlider) {
            VStack(spacing: 20) {
                Text("Adjust Hours Range")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.calendarDarkBlue)
                
                CalendarHourRangeSlider(
                    startHour: $startHour,
                    endHour: $endHour
                )
                .frame(width: 60)
                
                Button("Done") {
                    showFullSlider = false
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.calendarDarkBlue)
                .cornerRadius(12)
            }
            .padding()
            .presentationDetents([.height(400)])
            .presentationDragIndicator(.visible)
        }
    }
    
    private func formatHour(_ hour: Int) -> String {
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
}

// MARK: - Preview

#Preview("Hour Range Slider") {
    @State var startHour = 8
    @State var endHour = 18
    
    return VStack {
        CalendarHourRangeSlider(
            startHour: $startHour,
            endHour: $endHour
        )
        .frame(width: 60)
        
        Text("Range: \(startHour):00 - \(endHour):00")
            .padding()
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}

#Preview("Hour Range Compact") {
    @State var startHour = 6
    @State var endHour = 22
    
    return VStack {
        CalendarHourRangeCompact(
            startHour: $startHour,
            endHour: $endHour
        )
        .padding()
        
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
