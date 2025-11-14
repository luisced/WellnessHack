import SwiftUI

// MARK: - Custom Transition Modifiers

/// Modificadores de transición personalizados para navegación entre screens
struct TransitionModifiers {
    
    // MARK: - Slide + Blur con Partículas (VapiChat)
    
    static func slideBlurWithParticles() -> AnyTransition {
        .asymmetric(
            insertion: AnyTransition.move(edge: .trailing)
                .combined(with: .opacity)
                .combined(with: .scale(scale: 0.95)),
            removal: AnyTransition.move(edge: .leading)
                .combined(with: .opacity)
                .combined(with: .scale(scale: 1.05))
        )
    }
    
    // MARK: - Zoom desde Centro (FocusScreen)
    
    static func zoomFromCenter() -> AnyTransition {
        .scale(scale: 0.8)
            .combined(with: .opacity)
    }
    
    // MARK: - Gradiente Smooth (Calendar ↔ Dashboard)
    
    static func smoothGradient() -> AnyTransition {
        .opacity
            .combined(with: .scale(scale: 0.98))
    }
    
    // MARK: - Slide Simple (Dashboard → VapiChat)
    
    static func simpleFadeSlide() -> AnyTransition {
        .asymmetric(
            insertion: AnyTransition.move(edge: .bottom)
                .combined(with: .opacity),
            removal: AnyTransition.move(edge: .top)
                .combined(with: .opacity)
        )
    }
}

// MARK: - Particle Effect View (Para VapiChat)

struct ParticleEffect: View {
    @State private var particles: [Particle] = []
    let particleCount = 15
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(Color.white.opacity(particle.opacity))
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .blur(radius: 2)
            }
        }
        .onAppear {
            generateParticles()
            animateParticles()
        }
    }
    
    private func generateParticles() {
        particles = (0..<particleCount).map { _ in
            Particle(
                position: CGPoint(
                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                ),
                size: CGFloat.random(in: 4...12),
                opacity: Double.random(in: 0.1...0.3)
            )
        }
    }
    
    private func animateParticles() {
        withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
            for i in 0..<particles.count {
                particles[i].position.y -= CGFloat.random(in: 50...150)
                particles[i].opacity = Double.random(in: 0.0...0.2)
            }
        }
    }
}

struct Particle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGFloat
    var opacity: Double
}

// MARK: - Gradient Colors per Screen

extension Color {
    // VapiChat gradients
    static let vapiGradientStart = Color(hex: "87CEEB") // Azul cielo
    static let vapiGradientEnd = Color.white
    
    // Dashboard gradient (ya definido en GradientAnimationUtils)
    // FocusScreen y Calendar ya tienen sus gradientes
}
