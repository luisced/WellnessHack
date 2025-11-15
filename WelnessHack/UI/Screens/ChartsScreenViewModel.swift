import Foundation
import Combine
import HealthKit
import SwiftUI

@MainActor
class ChartsScreenViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var batteryLevel: Double = 0.0
    @Published var currentBodyBattery: BodyBatterySnapshot?
    @Published var sleepData: SleepData?
    @Published var activityData: ActivityData?
    @Published var hrvAverage: Double?
    @Published var lastWorkout: WorkoutData?
    
    @Published var bodyWeight: Double?
    @Published var bodyMassIndex: Double?
    @Published var caloriesConsumed: Double?
    @Published var waterIntake: Double?
    
    @Published var weeklyData: [(date: Date, score: Int)] = []
    @Published var weeklyActivity: [(date: Date, steps: Double, calories: Double, exercise: Double)] = []
    
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    // MARK: - Private Properties
    
    private let healthKitManager = HealthKitManager.shared
    private let bodyBatteryCalculator = BodyBatteryCalculator()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() {
        Task {
            await loadAllData()
        }
    }
    
    // MARK: - Data Loading
    
    func loadAllData() async {
        isLoading = true
        
        do {
            // Load current data
            await loadCurrentData()
            
            // Load weekly data
            await loadWeeklyData()
            
            isLoading = false
        } catch {
            errorMessage = "Error al cargar datos: \(error.localizedDescription)"
            showError = true
            isLoading = false
        }
    }
    
    func refreshData() async {
        await loadAllData()
    }
    
    // MARK: - Current Data
    
    private func loadCurrentData() async {
        // Fetch health data (handle errors gracefully)
        sleepData = try? await healthKitManager.fetchLastNightSleep()
        hrvAverage = try? await healthKitManager.fetchAverageHRV()
        activityData = try? await healthKitManager.fetchActivitySummary()
        lastWorkout = try? await healthKitManager.fetchLastWorkout()
        bodyWeight = try? await healthKitManager.fetchBodyWeight()
        bodyMassIndex = try? await healthKitManager.fetchBodyMassIndex()
        caloriesConsumed = try? await healthKitManager.fetchDailyCaloriesConsumed()
        waterIntake = try? await healthKitManager.fetchDailyWaterIntake()
        
        // Calculate body battery (even with partial data)
        currentBodyBattery = bodyBatteryCalculator.calculateBodyBattery(
            sleepData: sleepData,
            hrvAverage: hrvAverage,
            activityData: activityData
        )
        
        // Update battery level (0.0 - 1.0)
        if let battery = currentBodyBattery {
            batteryLevel = Double(battery.score) / 100.0
        }
        
        print("✅ Current data loaded:")
        print("   Battery: \(currentBodyBattery?.score ?? 0)/100")
        print("   Sleep: \(sleepData?.durationHours ?? 0)h")
        print("   HRV: \(hrvAverage ?? 0) ms")
        print("   Steps: \(activityData?.steps ?? 0)")
        print("   Weight: \(bodyWeight.map { String(format: "%.1f", $0) } ?? "N/A") kg")
        print("   BMI: \(bodyMassIndex.map { String(format: "%.1f", $0) } ?? "N/A")")
        print("   Calories: \(caloriesConsumed.map { String(format: "%.0f", $0) } ?? "N/A") kcal")
        print("   Water: \(waterIntake.map { String(format: "%.0f", $0) } ?? "N/A") ml")
        print("   Last workout: \(lastWorkout?.activityName ?? "None")")
    }
    
    // MARK: - Weekly Data
    
    private func loadWeeklyData() async {
        do {
            let calendar = Calendar.current
            let endDate = Date()
            guard let startDate = calendar.date(byAdding: .day, value: -7, to: endDate) else {
                return
            }
            
            var weeklyScores: [(date: Date, score: Int)] = []
            var activitySummaries: [(date: Date, steps: Double, calories: Double, exercise: Double)] = []
            
            // Load data for each day
            for dayOffset in 0..<7 {
                guard let dayStart = calendar.date(byAdding: .day, value: -dayOffset, to: calendar.startOfDay(for: endDate)) else {
                    continue
                }
                
                // Fetch daily data
                let dailySleep = try? await healthKitManager.fetchLastNightSleep()
                let dailyHRV = try? await healthKitManager.fetchAverageHRV(for: dayStart)
                let dailyActivity = try? await healthKitManager.fetchActivitySummary(for: dayStart)
                
                // Calculate daily body battery
                if let sleep = dailySleep, let activity = dailyActivity {
                    let snapshot = bodyBatteryCalculator.calculateBodyBattery(
                        sleepData: sleep,
                        hrvAverage: dailyHRV,
                        activityData: activity
                    )
                    weeklyScores.append((date: dayStart, score: snapshot.score))
                }
                
                // Store activity data
                if let activity = dailyActivity {
                    activitySummaries.append((
                        date: dayStart,
                        steps: Double(activity.steps),
                        calories: Double(activity.activeCalories),
                        exercise: Double(activity.exerciseMinutes)
                    ))
                }
            }
            
            // Sort by date (oldest first)
            weeklyData = weeklyScores.sorted { $0.date < $1.date }
            weeklyActivity = activitySummaries.sorted { $0.date < $1.date }
            
            print("✅ Weekly data loaded - \(weeklyData.count) days")
            
        } catch {
            print("⚠️ Error loading weekly data: \(error)")
        }
    }
    
    // MARK: - Computed Properties
    
    var sleepQualityPercentage: Double {
        guard let sleep = sleepData else { return 0 }
        return Double(sleep.quality) / 100.0
    }
    
    var hrvQualityPercentage: Double {
        guard let hrv = hrvAverage else { return 0 }
        // Normalize HRV (assume 50ms is good, scale accordingly)
        let normalized = min(hrv / 50.0, 2.0) // Cap at 2x good HRV
        return min(normalized / 2.0, 1.0) // Convert to 0-1 range
    }
    
    var activityPercentage: Double {
        guard let activity = activityData else { return 0 }
        // Based on steps goal of 10,000
        return min(Double(activity.steps) / 10000.0, 1.0)
    }
    
    var averageWeeklyScore: Int {
        guard !weeklyData.isEmpty else { return 0 }
        let sum = weeklyData.reduce(0) { $0 + $1.score }
        return sum / weeklyData.count
    }
    
    var weeklyDataPoints: [WeeklyDataPoint] {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "es_ES")
        dateFormatter.dateFormat = "EEE" // Lun, Mar, Mié, etc.
        
        return weeklyData.map { data in
            let dayName = dateFormatter.string(from: data.date).capitalized
            return WeeklyDataPoint(
                day: dayName,
                value: Double(data.score)
            )
        }
    }
    
    var pieChartDataPoints: [PieChartDataPoint] {
        return [
            PieChartDataPoint(
                id: UUID(),
                title: "Sueño",
                percentage: sleepQualityPercentage,
                color: .blue,
                description: sleepData != nil ? String(format: "%.1fh de sueño", sleepData!.durationHours) : "Sin datos"
            ),
            PieChartDataPoint(
                id: UUID(),
                title: "HRV",
                percentage: hrvQualityPercentage,
                color: .red,
                description: hrvAverage != nil ? String(format: "%.0f ms", hrvAverage!) : "Sin datos"
            ),
            PieChartDataPoint(
                id: UUID(),
                title: "Actividad",
                percentage: activityPercentage,
                color: .green,
                description: activityData != nil ? "\(activityData!.steps) pasos" : "Sin datos"
            )
        ]
    }
    
    var totalWeeklySteps: Int {
        let sum = weeklyActivity.reduce(0.0) { $0 + $1.steps }
        return Int(sum)
    }
    
    var totalWeeklyCalories: Int {
        let sum = weeklyActivity.reduce(0.0) { $0 + $1.calories }
        return Int(sum)
    }
    
    var averageSleepHours: Double {
        guard let sleep = sleepData else { return 0 }
        return sleep.durationHours
    }
}

