import SwiftUI

// MARK: - Typography System

extension Font {
    // MARK: - Display Fonts
    
    /// Large display text - 36pt, bold
    static let displayLarge = Font.system(size: 36, weight: .bold, design: .default)
    
    /// Medium display text - 28pt, bold
    static let displayMedium = Font.system(size: 28, weight: .bold, design: .default)
    
    /// Small display text - 24pt, semibold
    static let displaySmall = Font.system(size: 24, weight: .semibold, design: .default)
    
    // MARK: - Headline Fonts
    
    /// Large headline - 22pt, semibold
    static let headlineLarge = Font.system(size: 22, weight: .semibold, design: .default)
    
    /// Medium headline - 18pt, semibold
    static let headlineMedium = Font.system(size: 18, weight: .semibold, design: .default)
    
    /// Small headline - 16pt, semibold
    static let headlineSmall = Font.system(size: 16, weight: .semibold, design: .default)
    
    // MARK: - Body Fonts
    
    /// Large body text - 18pt, regular
    static let bodyLarge = Font.system(size: 18, weight: .regular, design: .default)
    
    /// Medium body text - 16pt, regular (default)
    static let bodyMedium = Font.system(size: 16, weight: .regular, design: .default)
    
    /// Small body text - 14pt, regular
    static let bodySmall = Font.system(size: 14, weight: .regular, design: .default)
    
    // MARK: - Caption & Label Fonts
    
    /// Large caption - 14pt, medium
    static let captionLarge = Font.system(size: 14, weight: .medium, design: .default)
    
    /// Medium caption - 12pt, regular
    static let captionMedium = Font.system(size: 12, weight: .regular, design: .default)
    
    /// Small caption - 10pt, regular
    static let captionSmall = Font.system(size: 10, weight: .regular, design: .default)
    
    // MARK: - Monospace Fonts (for timers, numbers)
    
    /// Large monospace - 36pt, bold
    static let monospaceLarge = Font.system(size: 36, weight: .bold, design: .monospaced)
    
    /// Medium monospace - 24pt, semibold
    static let monospaceMedium = Font.system(size: 24, weight: .semibold, design: .monospaced)
    
    /// Small monospace - 16pt, regular
    static let monospaceSmall = Font.system(size: 16, weight: .regular, design: .monospaced)
    
    // MARK: - Special Purpose Fonts
    
    /// Timer display - 40pt, bold, monospaced
    static let timer = Font.system(size: 40, weight: .bold, design: .monospaced)
    
    /// Button text - 16pt, semibold
    static let button = Font.system(size: 16, weight: .semibold, design: .default)
    
    /// Tab bar text - 10pt, medium
    static let tabBar = Font.system(size: 10, weight: .medium, design: .default)
}

// MARK: - Text Styles (ViewModifiers)

struct TrackingModifier: ViewModifier {
    let tracking: CGFloat
    
    func body(content: Content) -> some View {
        content.tracking(tracking)
    }
}

extension View {
    /// Aplica tracking/letter-spacing al texto
    /// - Parameter value: Espaciado entre letras (default: 1.2)
    func textTracking(_ value: CGFloat = 1.2) -> some View {
        self.modifier(TrackingModifier(tracking: value))
    }
    
    /// Estilo para títulos con tracking amplio
    func titleStyle() -> some View {
        self
            .font(.displayLarge)
            .tracking(3)
    }
}
