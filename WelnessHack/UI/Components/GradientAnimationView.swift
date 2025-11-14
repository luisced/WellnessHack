import SwiftUI

// MARK: - Gradient Animation Utility Functions

struct GradientAnimationUtils {
    
    /// Crea un gradiente animado que transiciona entre dos estados
    /// - Parameters:
    ///   - isReversed: Si true, invierte el orden de los colores
    ///   - animationDuration: Duración de la animación en segundos
    /// - Returns: LinearGradient animado
    static func createAnimatedGradient(isReversed: Bool, animationDuration: Double = 1.5) -> some View {
        LinearGradient(
            gradient: Gradient(colors: getGradientColors(isReversed: isReversed)),
            startPoint: .bottomLeading,
            endPoint: .topTrailing
        )
        .animation(.easeInOut(duration: animationDuration), value: isReversed)
    }
    
    /// Obtiene los colores del gradiente en el orden especificado
    /// - Parameter isReversed: Si true, invierte el orden de los colores
    /// - Returns: Array de colores para el gradiente
    static func getGradientColors(isReversed: Bool) -> [Color] {
        let baseColors = [
            Color.gradientDarkBlue,   // #365069 al 80%
            Color.gradientMediumBlue, // #6C949C al 70%
            Color.gradientMint,       // #A2D9CE al 35%
            Color.gradientWhite       // #EBEFF5 al 3%
        ]
        
        return isReversed ? baseColors.reversed() : baseColors
    }
    
    /// Función de transición suave entre pantallas con gradiente animado
    /// - Parameters:
    ///   - fromScreen: Pantalla de origen
    ///   - toScreen: Pantalla de destino
    ///   - isReversed: Dirección de la animación del gradiente
    /// - Returns: View con transición animada
    static func transitionWithGradient<Content: View>(
        content: Content,
        isReversed: Bool,
        animationDuration: Double = 1.5
    ) -> some View {
        ZStack {
            createAnimatedGradient(isReversed: isReversed, animationDuration: animationDuration)
                .ignoresSafeArea(.all)
            
            content
        }
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
        .animation(.easeInOut(duration: animationDuration), value: isReversed)
    }
}

// MARK: - Gradient Animation View

struct GradientAnimationView: View {
    let isReversed: Bool
    let animationDuration: Double = 1.5
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: gradientColors),
            startPoint: .bottomLeading,
            endPoint: .topTrailing
        )
        .animation(
            .easeInOut(duration: animationDuration),
            value: isReversed
        )
        .ignoresSafeArea(.all)
    }
    
    private var gradientColors: [Color] {
        let baseColors = [
            Color.gradientDarkBlue,   // #365069 al 80%
            Color.gradientMediumBlue, // #6C949C al 70%
            Color.gradientMint,       // #A2D9CE al 35%
            Color.gradientWhite       // #EBEFF5 al 3%
        ]
        
        return isReversed ? baseColors.reversed() : baseColors
    }
}

// MARK: - Animated Screen Container

struct AnimatedScreenContainer<Content: View>: View {
    let isReversed: Bool
    let content: Content
    
    @State private var animateGradient = false
    
    init(isReversed: Bool, @ViewBuilder content: () -> Content) {
        self.isReversed = isReversed
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            GradientAnimationView(isReversed: animateGradient ? isReversed : !isReversed)
            
            content
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5)) {
                animateGradient = true
            }
        }
        .onChange(of: isReversed) { _, newValue in
            withAnimation(.easeInOut(duration: 1.5)) {
                animateGradient = newValue
            }
        }
    }
}

// MARK: - Screen Transition Manager

class ScreenTransitionManager: ObservableObject {
    @Published var currentScreen: ScreenType = .graficas
    
    enum ScreenType {
        case graficas
        case calendar
    }
    
    func toggleScreen() {
        currentScreen = currentScreen == .graficas ? .calendar : .graficas
    }
    
    func navigateTo(_ screen: ScreenType) {
        currentScreen = screen
    }
    
    var isGradientReversed: Bool {
        currentScreen == .calendar
    }
}

// MARK: - Navigation View with Gradient Animation

struct GradientNavigationView: View {
    @StateObject private var transitionManager = ScreenTransitionManager()
    
    var body: some View {
        TabView(selection: $transitionManager.currentScreen) {
            // Gráficas Screen
            NavigationView {
                AnimatedScreenContainer(isReversed: false) {
                    graficasContent
                }
                .navigationTitle("Gráficas")
                .navigationBarTitleDisplayMode(.large)
            }
            .tag(ScreenTransitionManager.ScreenType.graficas)
            
            // Calendar Screen
            NavigationView {
                AnimatedScreenContainer(isReversed: true) {
                    calendarContent
                }
                .navigationTitle("Calendario")
                .navigationBarTitleDisplayMode(.large)
            }
            .tag(ScreenTransitionManager.ScreenType.calendar)
        }
        .environmentObject(transitionManager)
    }
    
    @ViewBuilder
    private var graficasContent: some View {
        ScrollView {
            VStack(spacing: 25) {
                Text("Gráficas de Energía")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                // Battery Charging Section with Spline
                BatteryChargingView(
                    batteryLevel: 0.75,
                    onBreakRequested: {
                        // TODO: Navigate to break screen
                        print("Navigate to break screen")
                    }
                )
                
                // Weekly Analysis Chart
                WeeklyAnalysisChartView()
                
                // Pie Charts Analysis
                PieChartsAnalysisView()
                
                // Original Energy Dashboard (scaled down)
                EnergyDashboardView(
                    bodyBattery: sampleBodyBattery,
                    sleepData: sampleSleepData,
                    activityData: sampleActivityData
                )
                .scaleEffect(0.8)
                
                Button("Ir a Calendario") {
                    transitionManager.navigateTo(.calendar)
                }
                .padding()
                .background(Color.white.opacity(0.2))
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.top, 20)
            }
            .padding()
        }
    }
    
    @ViewBuilder
    private var calendarContent: some View {
        VStack(spacing: 0) {
            ModernCalendarView(viewModel: CalendarViewModel())
            
            Button("Ir a Gráficas") {
                transitionManager.navigateTo(.graficas)
            }
            .padding()
            .background(Color.white.opacity(0.2))
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }
}

// MARK: - Sample Data (for preview)

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
    GradientNavigationView()
}
