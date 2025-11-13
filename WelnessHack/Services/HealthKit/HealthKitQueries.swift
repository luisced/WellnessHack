import Foundation
import HealthKit

struct HealthKitQueries {
    private let healthStore = HKHealthStore()
    
    // MARK: - Sleep Queries
    
    func fetchSleepData(from startDate: Date, to endDate: Date) async throws -> [HKCategorySample] {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            throw HealthKitError.dataNotAvailable
        }
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )
        
        return try await querySamples(
            type: sleepType,
            predicate: predicate,
            sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        )
    }
    
    // MARK: - HRV Queries
    
    func fetchHRVData(from startDate: Date, to endDate: Date) async throws -> [HKQuantitySample] {
        guard let hrvType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
            throw HealthKitError.dataNotAvailable
        }
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )
        
        return try await queryQuantitySamples(
            type: hrvType,
            predicate: predicate,
            sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        )
    }
    
    func fetchAverageHRVForLastWeek() async throws -> Double? {
        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -7, to: endDate) else {
            return nil
        }
        
        let samples = try await fetchHRVData(from: startDate, to: endDate)
        guard !samples.isEmpty else { return nil }
        
        let unit = HKUnit.secondUnit(with: .milli)
        let values = samples.map { $0.quantity.doubleValue(for: unit) }
        return values.reduce(0, +) / Double(values.count)
    }
    
    // MARK: - Heart Rate Queries
    
    func fetchRestingHeartRateData(from startDate: Date, to endDate: Date) async throws -> [HKQuantitySample] {
        guard let hrType = HKObjectType.quantityType(forIdentifier: .restingHeartRate) else {
            throw HealthKitError.dataNotAvailable
        }
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )
        
        return try await queryQuantitySamples(
            type: hrType,
            predicate: predicate,
            sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        )
    }
    
    // MARK: - Activity Queries
    
    func fetchStepsData(from startDate: Date, to endDate: Date) async throws -> Double {
        guard let stepsType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            throw HealthKitError.dataNotAvailable
        }
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )
        
        return try await queryStatisticsSum(
            type: stepsType,
            predicate: predicate,
            unit: .count()
        )
    }
    
    func fetchActiveEnergyData(from startDate: Date, to endDate: Date) async throws -> Double {
        guard let energyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            throw HealthKitError.dataNotAvailable
        }
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )
        
        return try await queryStatisticsSum(
            type: energyType,
            predicate: predicate,
            unit: .kilocalorie()
        )
    }
    
    func fetchExerciseTimeData(from startDate: Date, to endDate: Date) async throws -> Double {
        guard let exerciseType = HKObjectType.quantityType(forIdentifier: .appleExerciseTime) else {
            throw HealthKitError.dataNotAvailable
        }
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )
        
        return try await queryStatisticsSum(
            type: exerciseType,
            predicate: predicate,
            unit: .minute()
        )
    }
    
    func fetchDistanceData(from startDate: Date, to endDate: Date) async throws -> Double {
        guard let distanceType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            throw HealthKitError.dataNotAvailable
        }
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )
        
        return try await queryStatisticsSum(
            type: distanceType,
            predicate: predicate,
            unit: .meter()
        )
    }
    
    // MARK: - Historical Data
    
    func fetchWeeklyActivitySummary() async throws -> [(date: Date, steps: Double, calories: Double, exercise: Double)] {
        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -7, to: endDate) else {
            return []
        }
        
        var summaries: [(date: Date, steps: Double, calories: Double, exercise: Double)] = []
        
        for dayOffset in 0..<7 {
            guard let dayStart = calendar.date(byAdding: .day, value: -dayOffset, to: calendar.startOfDay(for: endDate)),
                  let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else {
                continue
            }
            
            async let steps = fetchStepsData(from: dayStart, to: dayEnd)
            async let calories = fetchActiveEnergyData(from: dayStart, to: dayEnd)
            async let exercise = fetchExerciseTimeData(from: dayStart, to: dayEnd)
            
            let (stepsValue, caloriesValue, exerciseValue) = try await (steps, calories, exercise)
            summaries.append((date: dayStart, steps: stepsValue, calories: caloriesValue, exercise: exerciseValue))
        }
        
        return summaries.sorted { $0.date < $1.date }
    }
    
    // MARK: - Helper Methods
    
    private func querySamples<T: HKSample>(
        type: HKSampleType,
        predicate: NSPredicate?,
        sortDescriptors: [NSSortDescriptor]? = nil,
        limit: Int = HKObjectQueryNoLimit
    ) async throws -> [T] {
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: predicate,
                limit: limit,
                sortDescriptors: sortDescriptors
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: samples as? [T] ?? [])
            }
            healthStore.execute(query)
        }
    }
    
    private func queryQuantitySamples(
        type: HKQuantityType,
        predicate: NSPredicate?,
        sortDescriptors: [NSSortDescriptor]? = nil,
        limit: Int = HKObjectQueryNoLimit
    ) async throws -> [HKQuantitySample] {
        return try await querySamples(
            type: type,
            predicate: predicate,
            sortDescriptors: sortDescriptors,
            limit: limit
        )
    }
    
    private func queryStatisticsSum(
        type: HKQuantityType,
        predicate: NSPredicate?,
        unit: HKUnit
    ) async throws -> Double {
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: type,
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
}

