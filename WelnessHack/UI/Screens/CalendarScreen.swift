import SwiftUI

struct CalendarScreen: View {
    @StateObject private var viewModel = CalendarViewModel()
    
    var body: some View {
        // MARK: - Calendar Content with Gradient Background
        
        ModernCalendarView(viewModel: viewModel)
            .background(
                LinearGradient(
                    colors: [
                        Color(hex: "87CEEB"), // Azul claro (inferior izquierda)
                        Color.calendarMint    // Menta (superior derecha)
                    ],
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
