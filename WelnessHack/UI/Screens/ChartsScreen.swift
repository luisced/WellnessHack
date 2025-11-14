import SwiftUI

// MARK: - Charts Screen

struct ChartsScreen: View {
    @State private var showBreak = false
    @State private var batteryLevel: Double = 0.75
    
    var body: some View {
        ZStack {
            // Background with calendar gradient
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
            
            if showBreak {
                BreakScreen(onBackToMain: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showBreak = false
                    }
                })
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            } else {
                ScrollView {
                    VStack(spacing: 25) {
                        // Battery Charging Section with Spline
                        BatteryChargingView(
                            batteryLevel: batteryLevel,
                            onBreakRequested: {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    showBreak = true
                                }
                            }
                        )
                        
                        // Weekly Analysis Chart
                        WeeklyAnalysisChartView()
                        
                        // Pie Charts Analysis (Sleep, HRV, Stress)
                        PieChartsAnalysisView()
                    }
                    .padding()
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ChartsScreen()
}
