import SwiftUI

// MARK: - Gradient Transition Demo Screen

struct GradientTransitionDemo: View {
    @State private var showCalendar = false
    @State private var showBreak = false
    @State private var animateGradient = false
    
    var body: some View {
        ZStack {
            // Gradiente animado de fondo
            GradientAnimationUtils.createAnimatedGradient(
                isReversed: animateGradient,
                animationDuration: 1.5
            )
            .ignoresSafeArea(.all)
            
            // Contenido de la pantalla actual
            if showBreak {
                BreakScreen(onBackToMain: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showBreak = false
                    }
                })
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            } else {
                mainContent
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5)) {
                animateGradient = showCalendar
            }
        }
        .onChange(of: showCalendar) { _, newValue in
            withAnimation(.easeInOut(duration: 1.5)) {
                animateGradient = newValue
            }
        }
    }
    
    private var mainContent: some View {
        VStack(spacing: 30) {
            Text(showCalendar ? "Calendario" : "Gráficas")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            if showCalendar {
                calendarContent
            } else {
                graficasContent
            }
            
            // Botón de transición
            Button(action: toggleScreen) {
                HStack {
                    Image(systemName: showCalendar ? "chart.bar.fill" : "calendar")
                    Text(showCalendar ? "Ver Gráficas" : "Ver Calendario")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(12)
            }
        }
        .padding()
    }
    
    private func toggleScreen() {
        withAnimation(.easeInOut(duration: 0.8)) {
            showCalendar.toggle()
        }
    }
    
    @ViewBuilder
    private var graficasContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Battery Charging Section
                BatteryChargingView(
                    batteryLevel: 0.75,
                    onBreakRequested: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showBreak = true
                        }
                    }
                )
                .scaleEffect(0.9)
                
                // Weekly Analysis Chart
                WeeklyAnalysisChartView()
                    .scaleEffect(0.9)
                
                // Pie Charts Analysis
                PieChartsAnalysisView()
                    .scaleEffect(0.9)
            }
        }
        .scaleEffect(0.85)
    }
    
    @ViewBuilder
    private var calendarContent: some View {
        ModernCalendarView(viewModel: CalendarViewModel())
            .scaleEffect(0.85)
    }
}

// MARK: - Sample Data

private let sampleBodyBattery = BodyBatterySnapshot(
    score: 75,
    sleepScore: 80,
    hrvScore: 70,
    activityScore: 60,
    factors: ["Buen descanso", "HRV estable"],
    recommendations: ["Momento ideal para ejercicio"],
    sleepDuration: 28800,
    hrvAverage: 65,
    activityLevel: "moderate"
)

private let sampleSleepData = SleepData(
    duration: 28800,
    deepSleepDuration: 7200,
    remSleepDuration: 5400,
    coreSleepDuration: 14400,
    awakeDuration: 900,
    bedTime: Date().addingTimeInterval(-28800),
    wakeTime: Date(),
    quality: 80
)

private let sampleActivityData = ActivityData(
    steps: 8500,
    activeCalories: 450,
    exerciseMinutes: 35,
    distance: 6500,
    restingHeartRate: 62,
    intensity: .moderate
)

// MARK: - Preview

#Preview {
    GradientTransitionDemo()
}

#Preview("Calendar View") {
    GradientTransitionDemo()
        .onAppear {
            // Simulate showing calendar for preview
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // This would need to be handled differently in a real preview
            }
        }
}
