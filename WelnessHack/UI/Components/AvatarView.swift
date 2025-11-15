import SwiftUI
import SplineRuntime

/// Vista del avatar del chatbot con animación de glow cuando está activo
/// Usa el Spline 3D del robot rememberall
struct AvatarView: View {
    let isActive: Bool
    let imageURL: String?
    
    @State private var isGlowing = false
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Glow effect cuando está hablando
            if isActive {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.64, green: 0.85, blue: 0.81).opacity(0.3), // #A2D9CE
                                Color(red: 0.44, green: 0.68, blue: 0.88).opacity(0.2)  // #71ADE1
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 240, height: 240)
                    .scaleEffect(isGlowing ? 1.2 : 1.0)
                    .opacity(isGlowing ? 0 : 0.8)
                    .animation(
                        Animation.easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: false),
                        value: isGlowing
                    )
            }
            
            // Spline 3D Robot Avatar
            if let url = Bundle.main.url(
                forResource: "rememberall_robot_copy",
                withExtension: "splineswift"
            ) {
                SplineView(sceneFileURL: url)
                    .frame(width: 220, height: 220)
                    .scaleEffect(scale)
                    .shadow(color: Color(red: 0.64, green: 0.85, blue: 0.81).opacity(0.4), radius: 20, x: 0, y: 10)
                    .shadow(color: Color.black.opacity(0.2), radius: 30, x: 0, y: 15)
            } else {
                // Fallback si no se encuentra el archivo Spline
                avatarFallback
            }
        }
        .onAppear {
            if isActive {
                isGlowing = true
                startPulseAnimation()
            }
        }
        .onChange(of: isActive) { newValue in
            isGlowing = newValue
            if newValue {
                startPulseAnimation()
            } else {
                stopPulseAnimation()
            }
        }
    }
    
    // MARK: - Animations
    
    private func startPulseAnimation() {
        withAnimation(
            Animation.easeInOut(duration: 2.0)
                .repeatForever(autoreverses: true)
        ) {
            scale = 1.05
        }
    }
    
    private func stopPulseAnimation() {
        withAnimation(.easeOut(duration: 0.3)) {
            scale = 1.0
        }
    }
    
    // MARK: - Fallback Avatar
    
    private var avatarFallback: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.64, green: 0.85, blue: 0.81).opacity(0.3),
                            Color(red: 0.44, green: 0.68, blue: 0.88).opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 190, height: 190)
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 190, height: 190)
                )
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.6),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                .shadow(color: Color(red: 0.64, green: 0.85, blue: 0.81).opacity(0.3), radius: 15, x: 0, y: 8)
                .shadow(color: Color.black.opacity(0.1), radius: 30, x: 0, y: 15)
            
            Image(systemName: "brain.head.profile")
                .font(.system(size: 100))
                .foregroundColor(.white.opacity(0.9))
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack(spacing: 40) {
            AvatarView(isActive: false, imageURL: nil)
            AvatarView(isActive: true, imageURL: nil)
        }
    }
}
