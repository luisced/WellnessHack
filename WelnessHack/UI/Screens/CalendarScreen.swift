import SwiftUI

struct CalendarScreen: View {
    @StateObject private var viewModel = CalendarViewModel()
    
    var body: some View {
        // MARK: - Calendar Content with Gradient Background
        
        ModernCalendarView(viewModel: viewModel)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.calendarDarkBlue,     // 1C2B3A - Azul fuerte (inferior izquierda)
                        Color.calendarLightBlue,    // 456B8C - Azul leve (transición suave)
                        Color.calendarMint,         // A2D9CE - Menta (centro expandido)
                        Color.calendarWhite         // EBEFF5 - Blanco (superior derecha)
                    ]),
                    startPoint: .bottomLeading,
                    endPoint: .topTrailing
                )
                .ignoresSafeArea(.all)
            )
    }
}

// MARK: - Calendar Colors Extension

extension Color {
    static let calendarDarkBlue = Color(red: 0.11, green: 0.17, blue: 0.23)  // #1C2B3A
    static let calendarLightBlue = Color(red: 0.27, green: 0.42, blue: 0.55) // #456B8C
    static let calendarMint = Color(red: 0.64, green: 0.85, blue: 0.81)      // #A2D9CE
    static let calendarWhite = Color(red: 0.92, green: 0.94, blue: 0.96)     // #EBEFF5
}

// MARK: - Preview

#Preview {
    CalendarScreen()
}

#Preview("With Tab Bar") {
    TabView {
        CalendarScreen()
            .tabItem {
                Label("Calendar", systemImage: "calendar")
            }
    }
}
