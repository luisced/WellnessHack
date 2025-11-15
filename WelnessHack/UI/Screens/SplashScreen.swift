import SwiftUI
import SplineRuntime

struct SplashScreen: View {
    @Binding var isActive: Bool
    @State private var opacity: Double = 1.0
    @State private var scale: CGFloat = 0.8
    
    var body: some View {
        ZStack {
            // Fondo degradado
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.15),
                    Color(red: 0.1, green: 0.05, blue: 0.2),
                    Color.black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Spline 3D Robot centrado y ligeramente hacia arriba
                if let url = Bundle.main.url(
                    forResource: "rememberall_robot_copy",
                    withExtension: "splineswift"
                ) {
                    SplineView(sceneFileURL: url)
                        .frame(width: 300, height: 300)
                        .scaleEffect(scale)
                        .offset(y: -50) // Ligeramente hacia arriba
                } else {
                    // Fallback si no se encuentra el archivo
                    Circle()
                        .fill(Color.appAccent.opacity(0.3))
                        .frame(width: 200, height: 200)
                        .overlay(
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 80))
                                .foregroundColor(.appAccent)
                        )
                        .scaleEffect(scale)
                        .offset(y: -50)
                }
                
                // Texto de bienvenida
                VStack(spacing: 12) {
                    Text("Bienvenido a")
                        .font(.system(size: 24, weight: .light, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("Wellness Hack")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.appAccent)
                        .tracking(2)
                    
                    Text("Tu asistente de bienestar")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.top, 4)
                }
                .scaleEffect(scale)
                
                Spacer()
                Spacer()
            }
        }
        .opacity(opacity)
        .onAppear {
            // Animación de entrada
            withAnimation(.easeOut(duration: 0.8)) {
                scale = 1.0
            }
            
            // Esperar 2.5 segundos y luego desvanecer
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 1.0)) {
                    opacity = 0.0
                    scale = 1.1
                }
                
                // Marcar como inactivo después de la animación
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    isActive = false
                }
            }
        }
    }
}

#Preview {
    SplashScreen(isActive: .constant(true))
}
