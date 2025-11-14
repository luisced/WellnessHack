import SwiftUI

// MARK: - Main Tab View

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var previousTab = 0
    @State private var gradientColors: [Color] = []
    
    let tabs = CustomTabBar.defaultTabs
    
    var body: some View {
        ZStack {
            // Fondo con gradiente animado
            AnimatedGradientBackground(selectedTab: selectedTab)
                .ignoresSafeArea(.all)
            
            // Efecto de partículas para VapiChat
            if selectedTab == 0 {
                ParticleEffect()
                    .ignoresSafeArea(.all)
                    .transition(.opacity)
            }
            
            // Contenido de la pantalla actual
            screenContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom Tab Bar (sobre todo, respetando safe areas)
            VStack {
                Spacer()
                CustomTabBar(
                    selectedTab: $selectedTab,
                    tabs: tabs
                )
                .padding(.bottom, 0) // Respeta safe area inferior
            }
            .ignoresSafeArea(.keyboard) // Pero ignora teclado si aparece
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            previousTab = oldValue
            onTabChanged(from: oldValue, to: newValue)
        }
    }
    
    // MARK: - Screen Content
    
    @ViewBuilder
    private var screenContent: some View {
        Group {
            switch selectedTab {
            case 0:
                VapiChatScreen()
                    .transition(getTransition(from: previousTab, to: 0))
            case 1:
                FocusScreen()
                    .transition(getTransition(from: previousTab, to: 1))
            case 2:
                CalendarScreen()
                    .transition(getTransition(from: previousTab, to: 2))
            case 3:
                dashboardScreen
                    .transition(getTransition(from: previousTab, to: 3))
            default:
                VapiChatScreen()
            }
        }
        .animation(.timingCurve(0.4, 0, 0.2, 1, duration: 0.5), value: selectedTab) // Opción A: Apple-style timing
    }
    
    @ViewBuilder
    private var dashboardScreen: some View {
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
            .padding(.bottom, 100) // Espacio para tab bar
        }
    }
    
    // MARK: - Transition Logic
    
    private func getTransition(from: Int, to: Int) -> AnyTransition {
        // VapiChat transitions
        if to == 0 || from == 0 {
            return TransitionModifiers.slideBlurWithParticles()
        }
        
        // FocusScreen transitions
        if to == 1 || from == 1 {
            return TransitionModifiers.zoomFromCenter()
        }
        
        // Calendar ↔ Dashboard (gradiente suave)
        if (to == 2 && from == 3) || (to == 3 && from == 2) {
            return TransitionModifiers.smoothGradient()
        }
        
        // Default
        return TransitionModifiers.simpleFadeSlide()
    }
    
    // MARK: - Tab Change Handler
    
    private func onTabChanged(from oldTab: Int, to newTab: Int) {
        // Haptic feedback ya se hace en CustomTabBar
        
        // Actualizar gradiente con animación (Opción A: suave y elegante)
        withAnimation(.easeInOut(duration: 0.8)) {
            gradientColors = getGradientColors(for: newTab)
        }
    }
    
    private func getGradientColors(for tab: Int) -> [Color] {
        switch tab {
        case 0: // VapiChat
            return [Color.vapiGradientStart, Color.vapiGradientEnd]
        case 1: // FocusScreen (ya tiene su propio gradiente)
            return [Color.focusBackground, Color.focusBlue.opacity(0.3)]
        case 2, 3: // Calendar y Dashboard
            return [
                Color.gradientDarkBlue,
                Color.gradientMediumBlue,
                Color.gradientMint,
                Color.gradientWhite
            ]
        default:
            return [Color.white, Color.white]
        }
    }
}

// MARK: - Animated Gradient Background

struct AnimatedGradientBackground: View {
    let selectedTab: Int
    
    var body: some View {
        Group {
            switch selectedTab {
            case 0: // VapiChat
                LinearGradient(
                    colors: [Color.vapiGradientStart, Color.vapiGradientEnd],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case 1: // FocusScreen - usa su propio background
                Color.clear
            case 2: // Calendar - gradiente hacia menta
                LinearGradient(
                    colors: [
                        Color.gradientMint,
                        Color.gradientWhite,
                        Color.calendarWhite
                    ],
                    startPoint: .bottomLeading,
                    endPoint: .topTrailing
                )
            case 3: // Dashboard - gradiente completo
                GradientAnimationUtils.createAnimatedGradient(
                    isReversed: false,
                    animationDuration: 1.0
                )
            default:
                Color.white
            }
        }
        .animation(.easeInOut(duration: 0.8), value: selectedTab) // Opción A: 0.8s smooth
    }
}

// MARK: - Preview

#Preview {
    MainTabView()
}

#Preview("Tab 1 - VapiChat") {
    MainTabView()
        .onAppear {
            // Show VapiChat by default
        }
}

#Preview("Tab 2 - Focus") {
    @Previewable @State var selectedTab = 1
    MainTabView()
}

#Preview("Tab 3 - Calendar") {
    @Previewable @State var selectedTab = 2
    MainTabView()
}

#Preview("Tab 4 - Dashboard") {
    @Previewable @State var selectedTab = 3
    MainTabView()
}
