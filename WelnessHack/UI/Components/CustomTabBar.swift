import SwiftUI

// MARK: - Custom Tab Bar

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [TabItem]
    
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                TabBarButton(
                    tab: tab,
                    isSelected: selectedTab == index,
                    namespace: animation
                ) {
                    selectTab(index)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(Color.clear) // Fondo completamente transparente
        .padding(.horizontal, 40) // Más compacta
        .padding(.bottom, 8) // Altura consistente en todas las pantallas
        .drawingGroup() // Mejora performance de animaciones con Metal rendering
    }
    
    private func selectTab(_ index: Int) {
        // Animación de selección (Opción A: Apple-style smooth)
        withAnimation(.spring(response: 0.5, dampingFraction: 0.85, blendDuration: 0)) {
            selectedTab = index
        }
        
        // Haptic feedback con timing perfecto (ligeramente retrasado)
        HapticManager.shared.selectionWithDelay()
    }
}

// MARK: - Tab Bar Button

struct TabBarButton: View {
    let tab: TabItem
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            // Solo ícono animado (sin texto, sin indicador)
            Image(systemName: tab.icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(isSelected ? Color.calendarDarkBlue : Color.white.opacity(0.4))
                .scaleEffect(isSelected ? 1.2 : 1.0)
                .animation(.spring(response: 0.5, dampingFraction: 0.85, blendDuration: 0), value: isSelected)
                .frame(width: 50, height: 50) // Touch target generoso
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Tab Item Model

struct TabItem: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let screen: TabScreen
}

enum TabScreen {
    case vapi
    case focus
    case calendar
    case dashboard
}

// MARK: - Tab Items Configuration

extension CustomTabBar {
    static var defaultTabs: [TabItem] {
        [
            TabItem(
                title: "Chat",
                icon: "mic.circle.fill",
                color: Color.calendarDarkBlue, // Azul fuerte para todos
                screen: .vapi
            ),
            TabItem(
                title: "Calendar",
                icon: "calendar",
                color: Color.calendarDarkBlue,
                screen: .calendar
            ),
            TabItem(
                title: "Stats",
                icon: "chart.line.uptrend.xyaxis",
                color: Color.calendarDarkBlue, // Azul fuerte para todos
                screen: .dashboard
            ),
            TabItem(
                title: "Focus",
                icon: "clock.fill",
                color: Color.calendarDarkBlue,
                screen: .focus
            )
        ]
    }
}
