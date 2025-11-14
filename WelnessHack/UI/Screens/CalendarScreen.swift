import SwiftUI

struct CalendarScreen: View {
    @StateObject private var viewModel = CalendarViewModel()
    
    var body: some View {
        ZStack {
            // MARK: - Gradient Background
            
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color.calendarDarkBlue, location: 0.0),    // 1C2B3A - Azul fuerte (arriba)
                    .init(color: Color.calendarLightBlue, location: 0.3),   // 456B8C - Azul leve (medio-superior)
                    .init(color: Color.calendarMint, location: 0.7),        // A2D9CE - Menta (medio-inferior)
                    .init(color: Color.calendarWhite, location: 1.0)        // EBEFF5 - Blanco (abajo)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(.all)
            
            // MARK: - Content Overlay
            
            VStack(spacing: 0) {
                // TODO: FRONTEND - Agregar contenido del calendario
                // - Header con mes/año
                // - Vista de calendario
                // - Lista de eventos del día
                // - Botón para agregar evento
                
                Spacer()
                
                Text("Calendar View")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Coming Soon")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
            }
        }
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
