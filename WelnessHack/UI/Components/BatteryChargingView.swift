import SwiftUI

// MARK: - Battery Charging View

struct BatteryChargingView: View {
    let batteryLevel: Double // 0.0 to 1.0
    let onBreakRequested: () -> Void
    
    var body: some View {
        Color.clear
    }
    
    // MARK: - Spline Battery View
    
    private var splineBatteryView: some View {
        ZStack {
            // Spline background for battery charging animation
            if let url = Bundle.main.url(
                forResource: "battery_charging_animation_copy",
                withExtension: "splineswift"
            ) {
                SplineView(sceneFileURL: url)
                    .frame(height: 200)
                    .scaleEffect(1.2)
                    .clipped()
            } else {
                // Fallback battery animation
                fallbackBatteryAnimation
            }
            
            // Battery percentage overlay
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text("\(Int(batteryLevel * 100))%")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 2)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
        }
        .frame(height: 200)
        .background(Color.black.opacity(0.1))
        .cornerRadius(20)
    }
    
    // MARK: - Fallback Battery Animation
    
    private var fallbackBatteryAnimation: some View {
        ZStack {
            // Battery shape
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(0.3), lineWidth: 3)
                .frame(width: 120, height: 60)
            
            // Battery fill
            RoundedRectangle(cornerRadius: 6)
                .fill(
                    LinearGradient(
                        colors: batteryGradientColors,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: CGFloat(batteryLevel * 108), height: 48)
                .animation(.easeInOut(duration: 1.0), value: batteryLevel)
            
            // Battery cap
            Rectangle()
                .fill(Color.white.opacity(0.3))
                .frame(width: 8, height: 20)
                .offset(x: 64)
            
            // Charging bolt
            Image(systemName: "bolt.fill")
                .font(.system(size: 24))
                .foregroundColor(.white)
                .opacity(0.8)
        }
        .scaleEffect(1.5)
    }
    
    // MARK: - Battery Level Meter
    
    private var batteryLevelMeter: some View {
        VStack(spacing: 15) {
            Text("Nivel de Energía")
                .font(.headline)
                .foregroundColor(.white)
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 20)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [
                                    batteryColor(for: batteryLevel),
                                    batteryColor(for: batteryLevel).opacity(0.8)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * batteryLevel, height: 20)
                        .animation(.easeInOut(duration: 1.0), value: batteryLevel)
                    
                    // Level text
                    HStack {
                        Text("\(Int(batteryLevel * 100)) ")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.leading, 8)
                        Spacer()
                        Text("100")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.trailing, 8)
                    }
                }
            }
            .frame(height: 20)
            
            // Status text
            Text(batteryStatusText)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
        }
        .padding(.horizontal, 10)
    }
    
    // MARK: - Take Break Button
    
    private var takeBreakButton: some View {
        Button(action: onBreakRequested) {
            VStack(spacing: 5) {
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 18))
                
                Text("Tomar un Break")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 15)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.25),
                        Color.white.opacity(0.15)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .cornerRadius(25)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(1.0)
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Helper Properties
    
    private var batteryGradientColors: [Color] {
        let level = batteryLevel
        if level > 0.6 {
            return [.green, .mint]
        } else if level > 0.3 {
            return [.orange, .yellow]
        } else {
            return [.red, .orange]
        }
    }
    
    private func batteryColor(for level: Double) -> Color {
        if level > 0.6 {
            return .green
        } else if level > 0.3 {
            return .orange
        } else {
            return .red
        }
    }
    
    private var batteryStatusText: String {
        let level = batteryLevel
        if level > 0.8 {
            return "Excelente nivel de energía"
        } else if level > 0.6 {
            return "Buen nivel de energía"
        } else if level > 0.3 {
            return "Nivel de energía moderado"
        } else {
            return "Bajo nivel de energía - Considera un break"
        }
    }
}

// MARK: - Preview

#Preview("High Battery") {
    ZStack {
        Color.black.ignoresSafeArea()
        BatteryChargingView(
            batteryLevel: 0.85,
            onBreakRequested: { print("Break requested") }
        )
    }
}

#Preview("Low Battery") {
    ZStack {
        Color.black.ignoresSafeArea()
        BatteryChargingView(
            batteryLevel: 0.25,
            onBreakRequested: { print("Break requested") }
        )
    }
}
