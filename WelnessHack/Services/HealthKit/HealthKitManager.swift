import Foundation
import HealthKit
import Combine

@MainActor
class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    
    private let healthStore = HKHealthStore()
    @Published var isAuthorized = false
    
    private init() {}
    
    // MARK: - Authorization
    
    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.notAvailable
        }
        
        let typesToRead: Set<HKObjectType> = [
            // Sleep
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            
            // HRV
            HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
            
            // Heart Rate
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
            
            // Activity
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            
            // Workouts
            HKObjectType.workoutType()
        ]
        
        // Don't request write permissions for now - only read
        try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
        isAuthorized = true
    }
    
    // MARK: - Sleep Data
    
    func fetchLastNightSleep() async throws -> SleepData {
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        
        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        let startOfYesterday = calendar.date(byAdding: .day, value: -1, to: startOfToday)!
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfYesterday,
            end: now,
            options: .strictStartDate
        )
        
        let samples = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKCategorySample], Error>) in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: samples as? [HKCategorySample] ?? [])
            }
            healthStore.execute(query)
        }
        
        return processSleepSamples(samples)
    }
    
    private func processSleepSamples(_ samples: [HKCategorySample]) -> SleepData {
        var totalSleepDuration: TimeInterval = 0
        var deepSleepDuration: TimeInterval = 0
        var remSleepDuration: TimeInterval = 0
        var coreSleepDuration: TimeInterval = 0
        var awakeDuration: TimeInterval = 0
        
        var bedTime: Date?
        var wakeTime: Date?
        
        for sample in samples {
            let duration = sample.endDate.timeIntervalSince(sample.startDate)
            
            if bedTime == nil || sample.startDate < bedTime! {
                bedTime = sample.startDate
            }
            if wakeTime == nil || sample.endDate > wakeTime! {
                wakeTime = sample.endDate
            }
            
            switch sample.value {
            case HKCategoryValueSleepAnalysis.asleepDeep.rawValue:
                deepSleepDuration += duration
                totalSleepDuration += duration
            case HKCategoryValueSleepAnalysis.asleepREM.rawValue:
                remSleepDuration += duration
                totalSleepDuration += duration
            case HKCategoryValueSleepAnalysis.asleepCore.rawValue:
                coreSleepDuration += duration
                totalSleepDuration += duration
            case HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue:
                totalSleepDuration += duration
            case HKCategoryValueSleepAnalysis.awake.rawValue:
                awakeDuration += duration
            default:
                break
            }
        }
        
        let deepSleepPercentage = totalSleepDuration > 0 ? (deepSleepDuration / totalSleepDuration) * 100 : 0
        let quality = calculateSleepQuality(
            duration: totalSleepDuration,
            deepPercentage: deepSleepPercentage,
            awakeTime: awakeDuration
        )
        
        return SleepData(
            duration: totalSleepDuration,
            deepSleepDuration: deepSleepDuration,
            remSleepDuration: remSleepDuration,
            coreSleepDuration: coreSleepDuration,
            awakeDuration: awakeDuration,
            bedTime: bedTime,
            wakeTime: wakeTime,
            quality: quality
        )
    }
    
    private func calculateSleepQuality(duration: TimeInterval, deepPercentage: Double, awakeTime: TimeInterval) -> Int {
        let hoursSlept = duration / 3600
        
        // Base score from duration (0-40 points)
        let durationScore = min(40, (hoursSlept / 8.0) * 40)
        
        // Deep sleep score (0-40 points)
        let deepScore = min(40, (deepPercentage / 25.0) * 40)
        
        // Awake time penalty (0-20 points)
        let awakeMinutes = awakeTime / 60
        let awakeScore = max(0, 20 - (awakeMinutes / 30.0) * 20)
        
        return Int(durationScore + deepScore + awakeScore)
    }
    
    // MARK: - HRV Data
    
    func fetchAverageHRV(for date: Date = Date()) async throws -> Double? {
        let hrvType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: endOfDay,
            options: .strictStartDate
        )
        
        let samples = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKQuantitySample], Error>) in
            let query = HKSampleQuery(
                sampleType: hrvType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: samples as? [HKQuantitySample] ?? [])
            }
            healthStore.execute(query)
        }
        
        guard !samples.isEmpty else { return nil }
        
        let unit = HKUnit.secondUnit(with: .milli)
        let values = samples.map { $0.quantity.doubleValue(for: unit) }
        let average = values.reduce(0, +) / Double(values.count)
        
        return average
    }
    
    // MARK: - Activity Data
    
    func fetchActivitySummary(for date: Date = Date()) async throws -> ActivityData {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: endOfDay,
            options: .strictStartDate
        )
        
        // Fetch steps
        let steps = try await fetchQuantitySum(
            identifier: .stepCount,
            unit: .count(),
            predicate: predicate
        )
        
        // Fetch active calories
        let activeCalories = try await fetchQuantitySum(
            identifier: .activeEnergyBurned,
            unit: .kilocalorie(),
            predicate: predicate
        )
        
        // Fetch exercise minutes
        let exerciseMinutes = try await fetchQuantitySum(
            identifier: .appleExerciseTime,
            unit: .minute(),
            predicate: predicate
        )
        
        // Fetch distance
        let distance = try await fetchQuantitySum(
            identifier: .distanceWalkingRunning,
            unit: .meter(),
            predicate: predicate
        )
        
        // Fetch resting heart rate
        let restingHR = try await fetchRestingHeartRate(for: date)
        
        let intensity = determineActivityIntensity(
            steps: Int(steps),
            exerciseMinutes: Int(exerciseMinutes),
            activeCalories: Int(activeCalories)
        )
        
        return ActivityData(
            steps: Int(steps),
            activeCalories: Int(activeCalories),
            exerciseMinutes: Int(exerciseMinutes),
            distance: distance,
            restingHeartRate: restingHR,
            intensity: intensity
        )
    }
    
    private func fetchQuantitySum(identifier: HKQuantityTypeIdentifier, unit: HKUnit, predicate: NSPredicate) async throws -> Double {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: identifier) else {
            return 0
        }
        
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Double, Error>) in
            let query = HKStatisticsQuery(
                quantityType: quantityType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, statistics, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let sum = statistics?.sumQuantity()?.doubleValue(for: unit) ?? 0
                continuation.resume(returning: sum)
            }
            healthStore.execute(query)
        }
    }
    
    private func fetchRestingHeartRate(for date: Date) async throws -> Int? {
        guard let hrType = HKObjectType.quantityType(forIdentifier: .restingHeartRate) else {
            return nil
        }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: endOfDay,
            options: .strictStartDate
        )
        
        let samples = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKQuantitySample], Error>) in
            let query = HKSampleQuery(
                sampleType: hrType,
                predicate: predicate,
                limit: 1,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: samples as? [HKQuantitySample] ?? [])
            }
            healthStore.execute(query)
        }
        
        guard let sample = samples.first else { return nil }
        let bpm = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
        return Int(bpm)
    }
    
    private func determineActivityIntensity(steps: Int, exerciseMinutes: Int, activeCalories: Int) -> ActivityIntensity {
        if exerciseMinutes >= 45 || activeCalories >= 600 {
            return .high
        } else if exerciseMinutes >= 20 || activeCalories >= 300 || steps >= 8000 {
            return .moderate
        } else if steps >= 4000 || exerciseMinutes >= 10 {
            return .light
        } else {
            return .sedentary
        }
    }
    
    // MARK: - Workout Data
    
    func fetchLastWorkout() async throws -> WorkoutData? {
        let workoutType = HKObjectType.workoutType()
        
        let predicate = HKQuery.predicateForSamples(
            withStart: Date().addingTimeInterval(-7 * 24 * 3600), // Last 7 days
            end: Date(),
            options: .strictStartDate
        )
        
        let samples = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKWorkout], Error>) in
            let query = HKSampleQuery(
                sampleType: workoutType,
                predicate: predicate,
                limit: 1,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: samples as? [HKWorkout] ?? [])
            }
            healthStore.execute(query)
        }
        
        guard let workout = samples.first else { return nil }
        
        return WorkoutData(
            activityType: workout.workoutActivityType,
            startDate: workout.startDate,
            endDate: workout.endDate,
            duration: workout.duration,
            totalEnergyBurned: workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()),
            totalDistance: workout.totalDistance?.doubleValue(for: .meter())
        )
    }
}

// MARK: - Data Models

struct SleepData {
    let duration: TimeInterval
    let deepSleepDuration: TimeInterval
    let remSleepDuration: TimeInterval
    let coreSleepDuration: TimeInterval
    let awakeDuration: TimeInterval
    let bedTime: Date?
    let wakeTime: Date?
    let quality: Int // 0-100
    
    var durationHours: Double {
        duration / 3600
    }
    
    var deepSleepPercentage: Double {
        duration > 0 ? (deepSleepDuration / duration) * 100 : 0
    }
}

struct ActivityData {
    let steps: Int
    let activeCalories: Int
    let exerciseMinutes: Int
    let distance: Double // meters
    let restingHeartRate: Int?
    let intensity: ActivityIntensity
    
    var distanceKm: Double {
        distance / 1000
    }
}

enum ActivityIntensity: String {
    case sedentary = "sedentary"
    case light = "light"
    case moderate = "moderate"
    case high = "high"
}

// MARK: - Errors

struct WorkoutData {
    let activityType: HKWorkoutActivityType
    let startDate: Date
    let endDate: Date
    let duration: TimeInterval
    let totalEnergyBurned: Double?
    let totalDistance: Double?
    
    var activityName: String {
        switch activityType {
        case .running:
            return "Correr"
        case .walking:
            return "Caminar"
        case .cycling:
            return "Ciclismo"
        case .swimming:
            return "Natación"
        case .yoga:
            return "Yoga"
        case .functionalStrengthTraining:
            return "Fuerza"
        case .traditionalStrengthTraining:
            return "Pesas"
        case .hiking:
            return "Senderismo"
        case .dance:
            return "Baile"
        case .soccer:
            return "Fútbol"
        case .basketball:
            return "Baloncesto"
        case .tennis:
            return "Tenis"
        case .golf:
            return "Golf"
        case .boxing:
            return "Boxeo"
        case .martialArts:
            return "Artes Marciales"
        case .crossTraining:
            return "Cross Training"
        case .elliptical:
            return "Elíptica"
        case .rowing:
            return "Remo"
        case .stairs:
            return "Escaleras"
        case .stepTraining:
            return "Step"
        case .pilates:
            return "Pilates"
        case .climbing:
            return "Escalada"
        default:
            return "Ejercicio"
        }
    }
    
    var activityIcon: String {
        switch activityType {
        case .running:
            return "figure.run"
        case .walking:
            return "figure.walk"
        case .cycling:
            return "bicycle"
        case .swimming:
            return "figure.pool.swim"
        case .yoga:
            return "figure.mind.and.body"
        case .functionalStrengthTraining, .traditionalStrengthTraining:
            return "dumbbell.fill"
        case .hiking:
            return "figure.hiking"
        case .dance:
            return "figure.dance"
        case .soccer:
            return "soccerball"
        case .basketball:
            return "basketball.fill"
        case .tennis:
            return "tennisball.fill"
        case .golf:
            return "figure.golf"
        case .boxing, .martialArts:
            return "figure.boxing"
        case .crossTraining:
            return "figure.cross.training"
        case .elliptical:
            return "figure.elliptical"
        case .rowing:
            return "figure.rower"
        case .stairs, .stepTraining:
            return "figure.stairs"
        case .pilates:
            return "figure.pilates"
        case .climbing:
            return "figure.climbing"
        default:
            return "figure.mixed.cardio"
        }
    }
    
    var durationMinutes: Int {
        Int(duration / 60)
    }
    
    var distanceKm: Double? {
        guard let distance = totalDistance else { return nil }
        return distance / 1000
    }
}

enum HealthKitError: Error, LocalizedError {
    case notAvailable
    case authorizationDenied
    case dataNotAvailable
    
    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "HealthKit is not available on this device"
        case .authorizationDenied:
            return "HealthKit authorization was denied"
        case .dataNotAvailable:
            return "The requested health data is not available"
        }
    }
}

