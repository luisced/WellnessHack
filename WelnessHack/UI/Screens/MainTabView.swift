import SwiftUI

// MARK: - Swipe Direction Enum

enum SwipeDirection {
    case left, right, none
}

// MARK: - Transition Type Enum

enum TransitionType {
    case slideBlur, zoom, gradient, slide
}

// MARK: - Main Tab View

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var previousTab = 0
    @State private var gradientColors: [Color] = []
    
    // Swipe gesture states
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    @State private var dragDirection: SwipeDirection = .none
    @State private var transitionProgress: CGFloat = 0.0  // 0.0 a 1.0 para interpolación
    
    let tabs = CustomTabBar.defaultTabs
    
    // Swipe configuration
    private let swipeThreshold: CGFloat = 50
    private let velocityThreshold: CGFloat = 300
    private let elasticLimit: CGFloat = 30
    
    var body: some View {
        ZStack {
            // Fondo interpolado: transiciona suavemente entre color sólido y gradiente
            InterpolatedBackgroundView(
                selectedTab: selectedTab,
                previousTab: previousTab,
                progress: transitionProgress,
                isDragging: isDragging,
                dragOffset: dragOffset
            )
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
                .offset(x: isDragging ? dragOffset : 0)
                .gesture(swipeGesture)
            
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
                    .transition(getSwipeTransition(from: previousTab, to: 0))
            case 1:
                FocusScreen()
                    .transition(getSwipeTransition(from: previousTab, to: 1))
            case 2:
                CalendarScreen()
                    .transition(getSwipeTransition(from: previousTab, to: 2))
            case 3:
                dashboardScreen
                    .transition(getSwipeTransition(from: previousTab, to: 3))
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
    
    // MARK: - Base Color Layer
    
    private var baseColorLayer: some View {
        // Color azul celeste uniforme para todas las transiciones
        Color(red: 0.49, green: 0.77, blue: 0.89) // #7CC5E3 - Azul celeste suave
            .ignoresSafeArea(.all)
    }
    
    // MARK: - Swipe Gesture
    
    private var swipeGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let translation = value.translation.width
                
                // Determinar dirección
                if translation > 10 {
                    dragDirection = .right
                } else if translation < -10 {
                    dragDirection = .left
                } else {
                    dragDirection = .none
                }
                
                // Aplicar elastic bounds en los extremos
                if (selectedTab == 0 && translation > 0) || (selectedTab == 3 && translation < 0) {
                    // Elastic effect en los extremos
                    dragOffset = translation * 0.3
                    transitionProgress = 0.0
                } else {
                    dragOffset = translation
                    
                    // Calcular progress de transición (0.0 a 1.0)
                    let screenWidth = UIScreen.main.bounds.width
                    transitionProgress = min(abs(translation) / screenWidth, 1.0)
                }
                
                isDragging = true
            }
            .onEnded { value in
                let translation = value.translation.width
                let velocity = value.predictedEndTranslation.width - value.translation.width
                
                handleSwipeEnd(translation: translation, velocity: velocity)
                
                // Reset drag state
                withAnimation(.easeOut(duration: 0.3)) {
                    dragOffset = 0
                    isDragging = false
                    dragDirection = .none
                    transitionProgress = 0.0
                }
            }
    }
    
    // MARK: - Swipe Handler
    
    private func handleSwipeEnd(translation: CGFloat, velocity: CGFloat) {
        let isSignificantSwipe = abs(translation) > swipeThreshold || abs(velocity) > velocityThreshold
        
        guard isSignificantSwipe else { return }
        
        let targetTab: Int
        
        if translation > 0 && selectedTab > 0 {
            // Swipe right - go to previous tab
            targetTab = selectedTab - 1
            triggerHapticFeedback()
        } else if translation < 0 && selectedTab < 3 {
            // Swipe left - go to next tab
            targetTab = selectedTab + 1
            triggerHapticFeedback()
        } else {
            // Edge case - elastic bounce
            triggerElasticFeedback()
            return
        }
        
        // Update tab with animation
        withAnimation(.timingCurve(0.4, 0, 0.2, 1, duration: 0.5)) {
            selectedTab = targetTab
        }
    }
    
    // MARK: - Swipe Transition Logic
    
    private func getSwipeTransition(from: Int, to: Int) -> AnyTransition {
        let isMovingRight = to < from // Moving to previous tab (swipe right)
        
        // Determine base transition type based on screens involved
        let baseTransition = getBaseTransition(from: from, to: to)
        
        // Apply directional movement
        return applyDirectionalMovement(baseTransition, isMovingRight: isMovingRight)
    }
    
    private func getBaseTransition(from: Int, to: Int) -> TransitionType {
        // VapiChat transitions
        if from == 0 || to == 0 {
            return .slideBlur
        }
        
        // FocusScreen transitions
        if from == 1 || to == 1 {
            return .zoom
        }
        
        // Calendar ↔ Dashboard (gradiente suave)
        if (from == 2 && to == 3) || (from == 3 && to == 2) {
            return .gradient
        }
        
        // Default
        return .slide
    }
    
    private func applyDirectionalMovement(_ transitionType: TransitionType, isMovingRight: Bool) -> AnyTransition {
        let leadingEdge: Edge = isMovingRight ? .leading : .trailing
        let trailingEdge: Edge = isMovingRight ? .trailing : .leading
        
        switch transitionType {
        case .slideBlur:
            return .asymmetric(
                insertion: .move(edge: leadingEdge).combined(with: .opacity),
                removal: .move(edge: trailingEdge).combined(with: .opacity)
            )
        case .zoom:
            return .asymmetric(
                insertion: .move(edge: leadingEdge).combined(with: .opacity),
                removal: .move(edge: trailingEdge).combined(with: .opacity)
            )
        case .gradient:
            return .asymmetric(
                insertion: .move(edge: leadingEdge).combined(with: .opacity),
                removal: .move(edge: trailingEdge).combined(with: .opacity)
            )
        case .slide:
            return .asymmetric(
                insertion: .move(edge: leadingEdge),
                removal: .move(edge: trailingEdge)
            )
        }
    }
    
    // MARK: - Haptic Feedback
    
    private func triggerHapticFeedback() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    private func triggerElasticFeedback() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
    
    // MARK: - Tab Change Handler
    
    private func onTabChanged(from oldTab: Int, to newTab: Int) {
        // Haptic feedback ya se hace en CustomTabBar
        
        // Actualizar gradiente con animación sincronizada con transiciones
        withAnimation(.timingCurve(0.4, 0, 0.2, 1, duration: 0.5)) {
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

// MARK: - Interpolated Background View

struct InterpolatedBackgroundView: View {
    let selectedTab: Int
    let previousTab: Int
    let progress: CGFloat
    let isDragging: Bool
    let dragOffset: CGFloat
    
    var body: some View {
        ZStack {
            // Color base direccional - se adapta según la transición
            getTransitionBaseColor()
            
            // Gradiente interpolado
            if isDragging {
                interpolatedGradient
                    .opacity(progress)
            } else {
                currentTabBackground
            }
        }
    }
    
    // MARK: - Transition Base Color (Direccional)
    
    private func getTransitionBaseColor() -> Color {
        guard isDragging else {
            return getStaticBaseColor(for: selectedTab)
        }
        
        let targetTab = getTargetTab()
        
        // Matriz de colores base por transición direccional
        switch (selectedTab, targetTab) {
        case (0, 1):  // VapiChat → Focus (swipe left)
            return Color(red: 0.37, green: 0.72, blue: 0.84)  // #5FB8D7 - Azul celeste vibrante
            
        case (1, 0):  // Focus → VapiChat (swipe right)
            return Color(red: 0.53, green: 0.81, blue: 0.92)  // #87CEEB - Azul cielo suave
            
        default:
            return Color(red: 0.49, green: 0.77, blue: 0.89)  // #7CC5E3 - Default celeste
        }
    }
    
    private func getStaticBaseColor(for tab: Int) -> Color {
        switch tab {
        case 0:  // VapiChat - azul cielo
            return Color(red: 0.53, green: 0.81, blue: 0.92)
        case 1:  // Focus - azul celeste
            return Color(red: 0.49, green: 0.77, blue: 0.89)
        default:
            return Color(red: 0.49, green: 0.77, blue: 0.89)
        }
    }
    
    private var currentTabBackground: some View {
        Group {
            switch selectedTab {
            case 0: // VapiChat
                LinearGradient(
                    colors: [Color.vapiGradientStart, Color.vapiGradientEnd],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case 1: // FocusScreen - usa color base (azul celeste)
                Color.clear
            case 2: // Calendar - gradiente menta
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
                Color.clear
            }
        }
    }
    
    private var interpolatedGradient: some View {
        Group {
            // Determinar el target tab basado en la dirección
            let targetTab = getTargetTab()
            
            // Crear gradiente interpolado entre tabs
            if selectedTab == 1 && targetTab == 2 {
                // Focus → Calendar: de color sólido a gradiente
                LinearGradient(
                    colors: [
                        Color.gradientMint,
                        Color.gradientWhite,
                        Color.calendarWhite
                    ],
                    startPoint: .bottomLeading,
                    endPoint: .topTrailing
                )
            } else if selectedTab == 2 && targetTab == 1 {
                // Calendar → Focus: de gradiente a color sólido (fade out)
                Color.clear
            } else {
                // Otras transiciones usan el background del target
                Color.clear
            }
        }
    }
    
    private func getTargetTab() -> Int {
        // Determinar hacia qué tab nos movemos basado en dragOffset
        if dragOffset < 0 {
            // Swipe left → tab siguiente
            return min(selectedTab + 1, 3)
        } else if dragOffset > 0 {
            // Swipe right → tab anterior
            return max(selectedTab - 1, 0)
        }
        return selectedTab
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
