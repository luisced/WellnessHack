import SwiftUI

struct EnergyDashboardView: View {
    let bodyBattery: BodyBatterySnapshot?
    let sleepData: SleepData?
    let activityData: ActivityData?
    
    var body: some View {
        VStack(spacing: 20) {
            // Main Energy Circle
            BodyBatteryCircle(snapshot: bodyBattery)
            
            // Metrics Grid
            if let bodyBattery = bodyBattery {
                MetricsGrid(
                    bodyBattery: bodyBattery,
                    sleepData: sleepData,
                    activityData: activityData
                )
            }
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Body Battery Circle

struct BodyBatteryCircle: View {
    let snapshot: BodyBatterySnapshot?
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                .frame(width: 200, height: 200)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                )
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1.0), value: progress)
            
            // Center content
            VStack(spacing: 8) {
                Text(snapshot?.emoji ?? "⚡")
                    .font(.system(size: 40))
                
                Text("\(snapshot?.score ?? 0)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(scoreColor)
                
                Text(snapshot?.scoreLevel.rawValue.capitalized ?? "N/A")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var progress: CGFloat {
        guard let score = snapshot?.score else { return 0 }
        return CGFloat(score) / 100.0
    }
    
    private var scoreColor: Color {
        guard let level = snapshot?.scoreLevel else { return .gray }
        switch level {
        case .critical:
            return .red
        case .low:
            return .orange
        case .moderate:
            return .green
        case .high:
            return .blue
        }
    }
    
    private var gradientColors: [Color] {
        guard let level = snapshot?.scoreLevel else { return [.gray, .gray] }
        switch level {
        case .critical:
            return [.red, .orange]
        case .low:
            return [.orange, .yellow]
        case .moderate:
            return [.green, .cyan]
        case .high:
            return [.blue, .purple]
        }
    }
}

// MARK: - Metrics Grid

struct MetricsGrid: View {
    let bodyBattery: BodyBatterySnapshot
    let sleepData: SleepData?
    let activityData: ActivityData?
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            // Sleep metric
            MetricCard(
                icon: "moon.fill",
                title: "Sueño",
                value: sleepValue,
                subtitle: sleepSubtitle,
                color: .indigo
            )
            
            // HRV metric
            MetricCard(
                icon: "heart.fill",
                title: "HRV",
                value: hrvValue,
                subtitle: "ms",
                color: .red
            )
            
            // Activity metric
            MetricCard(
                icon: "figure.walk",
                title: "Actividad",
                value: activityValue,
                subtitle: activitySubtitle,
                color: .green
            )
        }
    }
    
    private var sleepValue: String {
        guard let sleep = sleepData else { return "--" }
        let hours = Int(sleep.durationHours)
        let minutes = Int((sleep.durationHours - Double(hours)) * 60)
        return "\(hours)h \(minutes)m"
    }
    
    private var sleepSubtitle: String {
        guard let sleep = sleepData else { return "N/A" }
        return "\(sleep.quality)/100"
    }
    
    private var hrvValue: String {
        guard let hrv = bodyBattery.hrvAverage else { return "--" }
        return String(format: "%.0f", hrv)
    }
    
    private var activityValue: String {
        guard let activity = activityData else { return "--" }
        if activity.steps >= 1000 {
            return String(format: "%.1fk", Double(activity.steps) / 1000.0)
        } else {
            return "\(activity.steps)"
        }
    }
    
    private var activitySubtitle: String {
        guard let activity = activityData else { return "N/A" }
        return activity.intensity.rawValue.capitalized
    }
}

// MARK: - Metric Card

struct MetricCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    EnergyDashboardView(
        bodyBattery: BodyBatterySnapshot(
            score: 75,
            sleepScore: 80,
            hrvScore: 70,
            activityScore: 60,
            factors: ["Buen descanso", "HRV estable"],
            recommendations: ["Momento ideal para ejercicio"],
            sleepDuration: 28800,
            hrvAverage: 65,
            activityLevel: "moderate"
        ),
        sleepData: SleepData(
            duration: 28800,
            deepSleepDuration: 7200,
            remSleepDuration: 5400,
            coreSleepDuration: 14400,
            awakeDuration: 900,
            bedTime: Date().addingTimeInterval(-28800),
            wakeTime: Date(),
            quality: 80
        ),
        activityData: ActivityData(
            steps: 8500,
            activeCalories: 450,
            exerciseMinutes: 35,
            distance: 6500,
            restingHeartRate: 62,
            intensity: .moderate
        )
    )
    .padding()
}

