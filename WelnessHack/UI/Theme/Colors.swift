import SwiftUI

// MARK: - Color Palette

extension Color {
    // MARK: - Calendar Colors
    
    /// #1C2B3A - Azul fuerte (inferior izquierda del gradiente)
    static let calendarDarkBlue = Color(red: 0.11, green: 0.17, blue: 0.23)
    
    /// #456B8C - Azul leve (transición suave)
    static let calendarLightBlue = Color(red: 0.27, green: 0.42, blue: 0.55)
    
    /// #A2D9CE - Menta (centro expandido)
    static let calendarMint = Color(red: 0.64, green: 0.85, blue: 0.81)
    
    /// #EBEFF5 - Blanco (superior derecha)
    static let calendarWhite = Color(red: 0.92, green: 0.94, blue: 0.96)
    
    // MARK: - Focus Colors
    
    /// #2D5D7B - Azul principal para Focus
    static let focusBlue = Color(red: 0.176, green: 0.364, blue: 0.482)
    
    /// #1A365D - Fondo de Focus
    static let focusBackground = Color(red: 0.102, green: 0.212, blue: 0.365)
    
    /// #A2D9CE - Verde menta para mensajes motivacionales
    static let motivationalGreen = Color(red: 0.64, green: 0.85, blue: 0.81)
    
    // MARK: - Energy/Body Battery Colors
    
    /// Verde - Energía alta (75-100)
    static let energyHigh = Color.green
    
    /// Amarillo - Energía media (50-74)
    static let energyMedium = Color.yellow
    
    /// Naranja - Energía baja (25-49)
    static let energyLow = Color.orange
    
    /// Rojo - Energía crítica (0-24)
    static let energyCritical = Color.red
    
    // MARK: - Semantic Colors
    
    /// Color de acento principal de la app
    static let appAccent = Color.calendarDarkBlue
    
    /// Color de fondo principal
    static let appBackground = Color(.systemBackground)
    
    /// Color de superficie secundaria
    static let appSurface = Color(.secondarySystemBackground)
    
    /// Color de texto primario
    static let textPrimary = Color(.label)
    
    /// Color de texto secundario
    static let textSecondary = Color(.secondaryLabel)
    
    /// Color de éxito
    static let success = Color.green
    
    /// Color de advertencia
    static let warning = Color.orange
    
    /// Color de error
    static let error = Color.red
    
    /// Color de información
    static let info = Color.blue
    
    // MARK: - Gradient Animation Colors
    
    /// #365069 - Azul oscuro (80% opacidad)
    static let gradientDarkBlue = Color(hex: "365069").opacity(0.8)
    
    /// #6C949C - Azul grisáceo (70% opacidad)
    static let gradientMediumBlue = Color(hex: "6C949C").opacity(0.7)
    
    /// #A2D9CE - Menta suave (35% opacidad)
    static let gradientMint = Color(hex: "A2D9CE").opacity(0.35)
    
    /// #EBEFF5 - Blanco casi transparente (3% opacidad)
    static let gradientWhite = Color(hex: "EBEFF5").opacity(0.03)
    
    // MARK: - Helper: Initialize from Hex
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
