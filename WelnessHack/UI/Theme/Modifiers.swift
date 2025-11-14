import SwiftUI

// MARK: - Card Style Modifier

struct CardStyle: ViewModifier {
    var backgroundColor: Color = Color.appSurface
    var padding: CGFloat = Spacing.cardPadding
    var cornerRadius: CGFloat = CornerRadius.card
    var shadowRadius: CGFloat = 4
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: .black.opacity(0.1), radius: shadowRadius, x: 0, y: 2)
    }
}

// MARK: - Glassmorphism Effect

struct GlassmorphismStyle: ViewModifier {
    var material: Material = .ultraThinMaterial
    var overlayOpacity: Double = 0.1
    var overlayColor: Color = .white
    
    func body(content: Content) -> some View {
        content
            .background(
                Rectangle()
                    .fill(material)
                    .overlay(
                        Rectangle()
                            .fill(overlayColor.opacity(overlayOpacity))
                    )
            )
    }
}

// MARK: - Button Style

struct PrimaryButtonStyle: ButtonStyle {
    var backgroundColor: Color = .appAccent
    var foregroundColor: Color = .white
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.button)
            .foregroundColor(foregroundColor)
            .padding(.horizontal, Spacing.xl)
            .padding(.vertical, Spacing.base)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.button)
                    .fill(backgroundColor)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    var borderColor: Color = .appAccent
    var foregroundColor: Color = .appAccent
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.button)
            .foregroundColor(foregroundColor)
            .padding(.horizontal, Spacing.xl)
            .padding(.vertical, Spacing.base)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.button)
                    .stroke(borderColor, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Loading Indicator

struct LoadingModifier: ViewModifier {
    var isLoading: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(isLoading)
                .opacity(isLoading ? 0.5 : 1.0)
            
            if isLoading {
                ProgressView()
                    .scaleEffect(1.5)
            }
        }
    }
}

// MARK: - Shimmer Effect (for loading states)

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        .clear,
                        .white.opacity(0.3),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 300
                }
            }
    }
}

// MARK: - View Extensions

extension View {
    /// Aplica estilo de card con glassmorphism
    func glassCard(
        material: Material = .ultraThinMaterial,
        padding: CGFloat = Spacing.cardPadding,
        cornerRadius: CGFloat = CornerRadius.card
    ) -> some View {
        self
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(material)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(Color.white.opacity(0.1))
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
    
    /// Aplica estilo de card estándar
    func cardStyle(
        backgroundColor: Color = Color.appSurface,
        padding: CGFloat = Spacing.cardPadding,
        cornerRadius: CGFloat = CornerRadius.card,
        shadowRadius: CGFloat = 4
    ) -> some View {
        self.modifier(CardStyle(
            backgroundColor: backgroundColor,
            padding: padding,
            cornerRadius: cornerRadius,
            shadowRadius: shadowRadius
        ))
    }
    
    /// Aplica glassmorphism
    func glassmorphism(
        material: Material = .ultraThinMaterial,
        overlayOpacity: Double = 0.1,
        overlayColor: Color = .white
    ) -> some View {
        self.modifier(GlassmorphismStyle(
            material: material,
            overlayOpacity: overlayOpacity,
            overlayColor: overlayColor
        ))
    }
    
    /// Muestra loading indicator sobre la vista
    func loading(_ isLoading: Bool) -> some View {
        self.modifier(LoadingModifier(isLoading: isLoading))
    }
    
    /// Aplica efecto shimmer (loading skeleton)
    func shimmer() -> some View {
        self.modifier(ShimmerModifier())
    }
    
    /// Aplica estilo de botón primario
    func primaryButton(
        backgroundColor: Color = .appAccent,
        foregroundColor: Color = .white
    ) -> some View {
        Button(action: {}) {
            self
        }
        .buttonStyle(PrimaryButtonStyle(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor
        ))
    }
    
    /// Aplica estilo de botón secundario
    func secondaryButton(
        borderColor: Color = .appAccent,
        foregroundColor: Color = .appAccent
    ) -> some View {
        Button(action: {}) {
            self
        }
        .buttonStyle(SecondaryButtonStyle(
            borderColor: borderColor,
            foregroundColor: foregroundColor
        ))
    }
}
