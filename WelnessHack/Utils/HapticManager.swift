import UIKit

// MARK: - Haptic Feedback Manager

class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    /// Feedback ligero al cambiar de tab
    func lightImpact() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    /// Feedback medio para acciones importantes
    func mediumImpact() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    /// Feedback de selección
    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    /// Feedback de selección con timing perfecto (ligeramente retrasado)
    func selectionWithDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
        }
    }
    
    /// Feedback de éxito
    func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    /// Feedback de error
    func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
}
