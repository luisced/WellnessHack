import SwiftUI

// MARK: - Charts Screen

struct ChartsScreen: View {
    @StateObject private var viewModel = ChartsScreenViewModel()
    @State private var showBreak = false
    
    var body: some View {
        ZStack {
            // Background with calendar gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.calendarDarkBlue,     // 1C2B3A - Azul fuerte (inferior izquierda)
                    Color.calendarLightBlue,    // 456B8C - Azul leve (transición suave)
                    Color.calendarMint,         // A2D9CE - Menta (centro expandido)
                    Color.calendarWhite         // EBEFF5 - Blanco (superior derecha)
                ]),
                startPoint: .bottomLeading,
                endPoint: .topTrailing
            )
            .ignoresSafeArea(.all)
            
            if showBreak {
                BreakScreen(onBackToMain: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showBreak = false
                    }
                })
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            } else {
                ZStack {
                ScrollView {
                    VStack(spacing: 25) {
                            // Header with current stats
                            if let battery = viewModel.currentBodyBattery {
                                HealthStatsHeaderView(
                                    bodyBattery: battery,
                                    sleepData: viewModel.sleepData,
                                    activityData: viewModel.activityData
                                )
                                .padding(.top, 20)
                            }
                            
                            // Last Workout Card
                            if let workout = viewModel.lastWorkout {
                                LastWorkoutCardView(workout: workout)
                            }
                            
                            // Weekly Analysis Chart with real data
                            WeeklyAnalysisChartView(
                                weeklyData: viewModel.weeklyDataPoints
                            )
                            
                            // Pie Charts Analysis with real data
                            PieChartsAnalysisView(
                                pieChartData: viewModel.pieChartDataPoints
                            )
                            
                            // Weekly Activity Summary
                            WeeklyActivitySummaryView(
                                totalSteps: viewModel.totalWeeklySteps,
                                totalCalories: viewModel.totalWeeklyCalories,
                                averageSleep: viewModel.averageSleepHours
                            )
                            
                            // Detailed Sleep Card (always show if we have sleep data)
                            if let sleep = viewModel.sleepData {
                                DetailedSleepCardView(sleepData: sleep)
                            }
                            
                            // Body Measurements Card (always show, even with partial data)
                            BodyMeasurementsCardView(
                                weight: viewModel.bodyWeight,
                                bmi: viewModel.bodyMassIndex
                            )
                            
                            // Nutrition Card (always show, even with partial data)
                            NutritionCardView(
                                caloriesConsumed: viewModel.caloriesConsumed,
                                waterIntake: viewModel.waterIntake
                            )
                        }
                        .padding()
                    }
                    .refreshable {
                        await viewModel.refreshData()
                    }
                    
                    // Loading overlay
                    if viewModel.isLoading {
                        ProgressView("Cargando datos...")
                    .padding()
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(10)
                    }
                }
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

// MARK: - Health Stats Header

struct HealthStatsHeaderView: View {
    let bodyBattery: BodyBatterySnapshot
    let sleepData: SleepData?
    let activityData: ActivityData?
    
    var body: some View {
        VStack(spacing: 16) {
            // Main score
            HStack(spacing: 20) {
                VStack {
                    Text("\(bodyBattery.score)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("Body Battery")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Divider()
                    .frame(height: 30)
                    .background(Color.white.opacity(0.3))
                
                VStack(alignment: .leading, spacing: 8) {
                    if let sleep = sleepData {
                        StatRow(
                            icon: "moon.fill",
                            title: "Sueño",
                            value: String(format: "%.1fh", sleep.durationHours),
                            color: .blue
                        )
                    }
                    
                    if let activity = activityData {
                        StatRow(
                            icon: "figure.walk",
                            title: "Pasos",
                            value: "\(activity.steps)",
                            color: .green
                        )
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
}

struct StatRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            Spacer()
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
    }
}

// MARK: - Weekly Activity Summary

struct WeeklyActivitySummaryView: View {
    let totalSteps: Int
    let totalCalories: Int
    let averageSleep: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Resumen Semanal")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            HStack(spacing: 20) {
                SummaryCard(
                    icon: "figure.walk",
                    title: "Pasos Totales",
                    value: "\(totalSteps)",
                    color: .green
                )
                
                SummaryCard(
                    icon: "flame.fill",
                    title: "Calorías",
                    value: "\(totalCalories)",
                    color: .orange
                )
                
                SummaryCard(
                    icon: "moon.fill",
                    title: "Sueño Prom.",
                    value: String(format: "%.1fh", averageSleep),
                    color: .blue
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct SummaryCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

// MARK: - Last Workout Card

struct LastWorkoutCardView: View {
    let workout: WorkoutData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: workout.activityIcon)
                    .font(.title2)
                    .foregroundColor(.orange)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Último Ejercicio")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text(workout.activityName)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(timeAgo(from: workout.startDate))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text("\(workout.durationMinutes) min")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                }
            }
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            HStack(spacing: 20) {
                if let calories = workout.totalEnergyBurned {
                    WorkoutStatView(
                        icon: "flame.fill",
                        value: String(format: "%.0f", calories),
                        unit: "kcal",
                        color: .red
                    )
                }
                
                if let distance = workout.distanceKm {
                    WorkoutStatView(
                        icon: "location.fill",
                        value: String(format: "%.2f", distance),
                        unit: "km",
                        color: .blue
                    )
                }
                
                WorkoutStatView(
                    icon: "clock.fill",
                    value: "\(workout.durationMinutes)",
                    unit: "min",
                    color: .green
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.orange.opacity(0.2),
                            Color.orange.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private func timeAgo(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        let hours = Int(interval / 3600)
        let days = Int(interval / 86400)
        
        if days > 0 {
            return days == 1 ? "Hace 1 día" : "Hace \(days) días"
        } else if hours > 0 {
            return hours == 1 ? "Hace 1 hora" : "Hace \(hours) horas"
        } else {
            return "Hace menos de 1 hora"
        }
    }
}

struct WorkoutStatView: View {
    let icon: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text(unit)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }
}

// MARK: - Body Measurements Card

struct BodyMeasurementsCardView: View {
    let weight: Double?
    let bmi: Double?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "figure.stand")
                    .font(.title2)
                    .foregroundColor(.purple)
                
                Text("Medidas Corporales")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            HStack(spacing: 20) {
                MeasurementStatView(
                    icon: "scalemass.fill",
                    title: "Peso",
                    value: weight != nil ? String(format: "%.1f", weight!) : "--",
                    unit: "kg",
                    color: .purple
                )
                
                MeasurementStatView(
                    icon: "chart.bar.fill",
                    title: "IMC",
                    value: bmi != nil ? String(format: "%.1f", bmi!) : "--",
                    unit: bmi != nil ? bmiCategory(bmi!) : "N/A",
                    color: bmi != nil ? bmiColor(bmi!) : .gray
                )
            }
            
            if weight == nil && bmi == nil {
                Text("💡 Agrega tu peso en la app de Salud para ver estas métricas")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.purple.opacity(0.2),
                            Color.purple.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private func bmiCategory(_ bmi: Double) -> String {
        switch bmi {
        case ..<18.5: return "Bajo"
        case 18.5..<25: return "Normal"
        case 25..<30: return "Sobrepeso"
        default: return "Alto"
        }
    }
    
    private func bmiColor(_ bmi: Double) -> Color {
        switch bmi {
        case ..<18.5: return .blue
        case 18.5..<25: return .green
        case 25..<30: return .orange
        default: return .red
        }
    }
}

struct MeasurementStatView: View {
    let icon: String
    let title: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

// MARK: - Nutrition Card

struct NutritionCardView: View {
    let caloriesConsumed: Double?
    let waterIntake: Double?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "fork.knife")
                    .font(.title2)
                    .foregroundColor(.yellow)
                
                Text("Nutrición Hoy")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            HStack(spacing: 20) {
                MeasurementStatView(
                    icon: "flame.fill",
                    title: "Consumidas",
                    value: caloriesConsumed != nil ? String(format: "%.0f", caloriesConsumed!) : "--",
                    unit: "kcal",
                    color: .orange
                )
                
                MeasurementStatView(
                    icon: "drop.fill",
                    title: "Agua",
                    value: waterIntake != nil ? String(format: "%.0f", waterIntake!) : "--",
                    unit: "ml",
                    color: .cyan
                )
            }
            
            if caloriesConsumed == nil && waterIntake == nil {
                Text("💡 Registra tu comida y agua en la app de Salud para ver estas métricas")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.yellow.opacity(0.2),
                            Color.orange.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Detailed Sleep Card

struct DetailedSleepCardView: View {
    let sleepData: SleepData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "moon.stars.fill")
                    .font(.title2)
                    .foregroundColor(.indigo)
                
                Text("Análisis de Sueño")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 12) {
                SleepDetailRow(
                    title: "Duración Total",
                    value: String(format: "%.1fh", sleepData.durationHours),
                    icon: "clock.fill",
                    color: .blue
                )
                
                SleepDetailRow(
                    title: "Sueño Profundo",
                    value: String(format: "%.0f%%", sleepData.deepSleepPercentage),
                    icon: "moon.zzz.fill",
                    color: .indigo
                )
                
                SleepDetailRow(
                    title: "Sueño REM",
                    value: String(format: "%.1fh", sleepData.remSleepDuration / 3600),
                    icon: "brain.head.profile",
                    color: .purple
                )
                
                SleepDetailRow(
                    title: "Calidad",
                    value: "\(sleepData.quality)/100",
                    icon: "star.fill",
                    color: .yellow
                )
                
                if let bedTime = sleepData.bedTime, let wakeTime = sleepData.wakeTime {
                    Divider()
                        .background(Color.white.opacity(0.2))
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Acostado")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.6))
                            Text(bedTime.formatted(date: .omitted, time: .shortened))
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right")
                            .foregroundColor(.white.opacity(0.4))
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Despertado")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.6))
                            Text(wakeTime.formatted(date: .omitted, time: .shortened))
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.indigo.opacity(0.2),
                            Color.purple.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.indigo.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct SleepDetailRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
}

// MARK: - Preview

#Preview {
    ChartsScreen()
}
