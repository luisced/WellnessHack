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
