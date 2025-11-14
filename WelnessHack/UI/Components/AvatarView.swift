import SwiftUI

/// Vista del avatar del chatbot con animación de glow cuando está activo
struct AvatarView: View {
    let isActive: Bool
    let imageURL: String?
    
    @State private var isGlowing = false
    
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
                    .frame(width: 220, height: 220)
                    .scaleEffect(isGlowing ? 1.15 : 1.0)
                    .opacity(isGlowing ? 0 : 0.8)
                    .animation(
                        Animation.easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: false),
                        value: isGlowing
                    )
            }
            
            // Avatar circle with glass effect
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
                .frame(width: 190, height: 190)
                .background(
                    // Glass blur effect
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 190, height: 190)
                )
                .overlay(
                    // Glass border
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
                .shadow(color: Color(red: 0.64, green: 0.85, blue: 0.81).opacity(0.3), radius: 15, x: 0, y: 8) // #A2D9CE
                .shadow(color: Color.black.opacity(0.1), radius: 30, x: 0, y: 15)
            
            // Avatar icon/image
            if let imageURL = imageURL, let url = URL(string: imageURL) {
                // TODO: Implementar AsyncImage cuando se tenga URL del avatar
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    avatarPlaceholder
                }
                .frame(width: 190, height: 190)
                .clipShape(Circle())
            } else {
                avatarPlaceholder
            }
        }
        .onAppear {
            if isActive {
                isGlowing = true
            }
        }
        .onChange(of: isActive) { newValue in
            isGlowing = newValue
        }
    }
    
    // MARK: - Placeholder
    
    private var avatarPlaceholder: some View {
        Image(systemName: "person.circle.fill")
            .font(.system(size: 100))
            .foregroundColor(.white.opacity(0.9))
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
