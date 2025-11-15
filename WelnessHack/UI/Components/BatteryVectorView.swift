import SwiftUI

// MARK: - Battery Vector View with Glass Morphism

struct BatteryVectorView: View {
    let batteryLevel: Double // 0.0 to 1.0
    
    var body: some View {
        ZStack {
            // Battery container
            batteryShape
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.4),
                            Color.white.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
                .frame(width: 140, height: 240)
            
            // Battery fill with glass morphism
            GeometryReader { geometry in
                let fillHeight = geometry.size.height * batteryLevel
                
                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    
                    // Filled portion
                    batteryShape
                        .fill(
                            LinearGradient(
                                colors: batteryGradientColors,
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .frame(height: fillHeight)
                        .overlay(
                            // Glass effect overlay
                            batteryShape
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.3),
                                            Color.white.opacity(0.1),
                                            Color.clear
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(height: fillHeight)
                        )
                        .overlay(
                            // Shimmer effect
                            batteryShape
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.5),
                                            Color.clear
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    lineWidth: 1
                                )
                                .frame(height: fillHeight)
                        )
                }
                .animation(.easeInOut(duration: 1.0), value: batteryLevel)
            }
            .frame(width: 140, height: 240)
            .clipShape(batteryShape)
            
            // Battery cap (terminal)
            batteryCap
                .offset(y: -125)
            
            // Charging indicator (if level is increasing)
            if batteryLevel < 1.0 {
                chargingIndicator
                    .offset(y: -80)
            }
        }
        .frame(width: 160, height: 260)
    }
    
    // MARK: - Battery Shape
    
    private var batteryShape: some Shape {
        RoundedRectangle(cornerRadius: 16)
    }
    
    // MARK: - Battery Cap
    
    private var batteryCap: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.4),
                        Color.white.opacity(0.2)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: 60, height: 20)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
            )
    }
    
    // MARK: - Charging Indicator
    
    private var chargingIndicator: some View {
        Image(systemName: "bolt.fill")
            .font(.system(size: 28))
            .foregroundColor(.yellow.opacity(0.9))
            .shadow(color: .yellow.opacity(0.5), radius: 8, x: 0, y: 0)
            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: batteryLevel)
    }
    
    // MARK: - Helper Properties
    
    private var batteryGradientColors: [Color] {
        let level = batteryLevel
        if level > 0.6 {
            // High battery - Green/Mint with transparency
            return [
                Color.green.opacity(0.8),
                Color.mint.opacity(0.6),
                Color.cyan.opacity(0.4)
            ]
        } else if level > 0.3 {
            // Medium battery - Orange/Yellow with transparency
            return [
                Color.orange.opacity(0.8),
                Color.yellow.opacity(0.6),
                Color.orange.opacity(0.4)
            ]
        } else {
            // Low battery - Red/Orange with transparency
            return [
                Color.red.opacity(0.8),
                Color.orange.opacity(0.6),
                Color.red.opacity(0.4)
            ]
        }
    }
}

// MARK: - Preview

#Preview("High Battery") {
    ZStack {
        Color.black.ignoresSafeArea()
        BatteryVectorView(batteryLevel: 0.85)
    }
}

#Preview("Medium Battery") {
    ZStack {
        Color.black.ignoresSafeArea()
        BatteryVectorView(batteryLevel: 0.45)
    }
}

#Preview("Low Battery") {
    ZStack {
        Color.black.ignoresSafeArea()
        BatteryVectorView(batteryLevel: 0.15)
    }
}
