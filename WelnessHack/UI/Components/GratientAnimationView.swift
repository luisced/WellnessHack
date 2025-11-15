//
//  GratientAnimationView.swift
//  WelnessHack
//
//  Created by iOS Lab UPMX on 14/11/25.
//

import SwiftUI
import Combine

// MARK: - Gradient Animation Utilities

struct GradientAnimationUtils {
    
    /// Crea un gradiente animado que transiciona entre dos estados
    /// - Parameters:
    ///   - isReversed: Si true, invierte el orden de los colores
    ///   - animationDuration: Duración de la animación en segundos
    /// - Returns: LinearGradient animado
    static func createAnimatedGradient(isReversed: Bool, animationDuration: Double = 1.0) -> some View {
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
}

// MARK: - Gradient Animation View (Charts Screen Background)

struct GradientAnimationView: View {
    let isReversed: Bool
    let animationDuration: Double = 1.5
    
    var body: some View {
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
    }
}

// MARK: - Animated Screen Container (Charts Screen Container)

struct AnimatedScreenContainer<Content: View>: View {
    let isReversed: Bool
    let content: Content
    
    init(isReversed: Bool, @ViewBuilder content: () -> Content) {
        self.isReversed = isReversed
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            GradientAnimationView(isReversed: false)
            content
        }
    }
}

// MARK: - Screen Transition Manager (For Charts Screen)

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
                
                // Pie Charts Analysis (Sleep, HRV, Stress)
                PieChartsAnalysisView()
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

// MARK: - Preview

#Preview {
    GradientNavigationView()
}
