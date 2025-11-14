import SwiftUI

// MARK: - Spacing System

/// Sistema de espaciado consistente basado en múltiplos de 4
enum Spacing {
    /// 4pt - Espaciado extra pequeño
    static let xs: CGFloat = 4
    
    /// 8pt - Espaciado pequeño
    static let sm: CGFloat = 8
    
    /// 12pt - Espaciado pequeño-mediano
    static let md: CGFloat = 12
    
    /// 16pt - Espaciado mediano (base)
    static let base: CGFloat = 16
    
    /// 20pt - Espaciado mediano-grande
    static let lg: CGFloat = 20
    
    /// 24pt - Espaciado grande
    static let xl: CGFloat = 24
    
    /// 32pt - Espaciado extra grande
    static let xxl: CGFloat = 32
    
    /// 40pt - Espaciado muy grande
    static let xxxl: CGFloat = 40
    
    /// 48pt - Espaciado máximo
    static let huge: CGFloat = 48
    
    /// 60pt - Espaciado para separación major
    static let massive: CGFloat = 60
    
    // MARK: - Semantic Spacing
    
    /// Espaciado entre elementos en una lista/stack
    static let itemSpacing: CGFloat = base
    
    /// Espaciado de padding horizontal en screens
    static let screenHorizontal: CGFloat = lg
    
    /// Espaciado de padding vertical en screens
    static let screenVertical: CGFloat = xl
    
    /// Espaciado entre secciones
    static let sectionSpacing: CGFloat = xxxl
    
    /// Espaciado interno de cards/components
    static let cardPadding: CGFloat = base
    
    /// Espaciado de botones
    static let buttonSpacing: CGFloat = lg
}

// MARK: - Corner Radius

enum CornerRadius {
    /// 4pt - Esquinas sutiles
    static let sm: CGFloat = 4
    
    /// 8pt - Esquinas estándar
    static let md: CGFloat = 8
    
    /// 12pt - Esquinas medianas
    static let lg: CGFloat = 12
    
    /// 16pt - Esquinas grandes
    static let xl: CGFloat = 16
    
    /// 20pt - Esquinas extra grandes
    static let xxl: CGFloat = 20
    
    /// Círculo perfecto
    static let circle: CGFloat = 1000
    
    // MARK: - Semantic Radii
    
    /// Radio para cards
    static let card: CGFloat = md
    
    /// Radio para botones
    static let button: CGFloat = lg
    
    /// Radio para sheets/modals
    static let sheet: CGFloat = xl
}

// MARK: - View Extensions

extension View {
    /// Aplica padding horizontal estándar de screen
    func screenPaddingHorizontal() -> some View {
        self.padding(.horizontal, Spacing.screenHorizontal)
    }
    
    /// Aplica padding vertical estándar de screen
    func screenPaddingVertical() -> some View {
        self.padding(.vertical, Spacing.screenVertical)
    }
    
    /// Aplica padding completo estándar de screen
    func screenPadding() -> some View {
        self
            .padding(.horizontal, Spacing.screenHorizontal)
            .padding(.vertical, Spacing.screenVertical)
    }
    
    /// Aplica padding estándar de card
    func cardPadding() -> some View {
        self.padding(Spacing.cardPadding)
    }
    
    /// Aplica corner radius estándar de card
    func cardCornerRadius() -> some View {
        self.clipShape(RoundedRectangle(cornerRadius: CornerRadius.card))
    }
}
