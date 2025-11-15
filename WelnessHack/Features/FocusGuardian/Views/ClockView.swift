import SwiftUI

/// Vista del reloj clickeable con estilo naranja/coral
struct ClockView: View {
    let isActive: Bool
    let onTap: () -> Void
    
    @State private var isPulsing = false
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Outer glow effect
                if isActive {
                    Circle()
                        .stroke(Color.calendarMint.opacity(0.2), lineWidth: 6)
                        .frame(width: 200, height: 200)
                        .scaleEffect(isPulsing ? 1.2 : 1.0)
                        .opacity(isPulsing ? 0 : 0.8)
                        .animation(
                            Animation.easeInOut(duration: 2.0)
                                .repeatForever(autoreverses: false),
                            value: isPulsing
                        )
                }
                
                // Main clock circle (más grande)
                Circle()
                    .stroke(Color.calendarMint.opacity(0.7), lineWidth: 8)
                    .frame(width: 160, height: 160)
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.2))
                            .frame(width: 160, height: 160)
                    )
                    .shadow(color: Color.calendarMint.opacity(0.3), radius: 20, x: 0, y: 10)
                
                // Clock hand (pointing to 12) - más grande
                Rectangle()
                    .fill(Color.calendarMint.opacity(0.7))
                    .frame(width: 6, height: 50)
                    .offset(y: -20)
                    .clipShape(RoundedRectangle(cornerRadius: 3))
                
                // Center dot - más grande
                Circle()
                    .fill(Color.calendarMint.opacity(0.7))
                    .frame(width: 12, height: 12)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            if isActive {
                isPulsing = true
            }
        }
        .onChange(of: isActive) { newValue in
            isPulsing = newValue
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.focusBackground.ignoresSafeArea()
        
        VStack(spacing: 40) {
            ClockView(isActive: false, onTap: {})
            ClockView(isActive: true, onTap: {})
        }
    }
}
