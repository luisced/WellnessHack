import SwiftUI

// MARK: - Battery Charging View

struct BatteryChargingView: View {
    let batteryLevel: Double // 0.0 to 1.0
    let onBreakRequested: () -> Void
    
    var body: some View {

        VStack(spacing: 24) {
            HStack(alignment: .center, spacing: 20) {
                // MARK: - Vector Battery Animation
                BatteryVectorView(batteryLevel: batteryLevel)
                    .frame(maxWidth: 180)
                
                VStack(alignment: .leading, spacing: 12) {
                    // Score de batería
                    Text("\(Int(batteryLevel * 100))%")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    // MARK: - Take Break Button
                    takeBreakButton
                }
            }
            
            // MARK: - Battery Level Meter
            batteryLevelMeter
        }
        .padding(.horizontal, 20)

        Color.clear
        
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
        }
        .padding(.horizontal, 10)
    }
    
    // MARK: - Take Break Button
    
    private var takeBreakButton: some View {
        Button(action: onBreakRequested) {
            VStack(spacing: 5) {
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 18))
                
                Text("Break")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 35)
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
