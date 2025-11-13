import Foundation

@MainActor
class BodyBatteryPredictor {
    
    // MARK: - Forecast Generation
    
    func generateForecast(
        currentScore: Int,
        currentTime: Date = Date(),
        hoursAhead: Int,
        plannedActivities: [PlannedActivity] = [],
        sleepData: SleepData?
    ) -> EnergyForecast {
        
        let hourlyPredictions = predictHourlyEnergy(
            startingScore: currentScore,
            startTime: currentTime,
            hoursAhead: hoursAhead,
            activities: plannedActivities,
            sleepData: sleepData
        )
        
        let insights = generateInsights(
            predictions: hourlyPredictions,
            activities: plannedActivities
        )
        
        return EnergyForecast(
            currentScore: currentScore,
            generatedAt: currentTime,
            hourlyPredictions: hourlyPredictions,
            insights: insights
        )
    }
    
    // MARK: - Hourly Predictions
    
    private func predictHourlyEnergy(
        startingScore: Int,
        startTime: Date,
        hoursAhead: Int,
        activities: [PlannedActivity],
        sleepData: SleepData?
    ) -> [HourlyPrediction] {
        
        var predictions: [HourlyPrediction] = []
        var currentScore = Double(startingScore)
        let calendar = Calendar.current
        
        for hour in 0..<hoursAhead {
            guard let hourTime = calendar.date(byAdding: .hour, value: hour, to: startTime) else {
                continue
            }
            
            let hourOfDay = calendar.component(.hour, from: hourTime)
            
            // Natural energy curve based on time of day
            let naturalChange = calculateNaturalEnergyChange(
                hourOfDay: hourOfDay,
                currentScore: currentScore,
                sleepQuality: sleepData?.quality ?? 70
            )
            
            // Activity impact
            let activityImpact = calculateActivityImpact(
                at: hourTime,
                activities: activities
            )
            
            // Calculate new score
            currentScore += naturalChange + activityImpact
            currentScore = max(0, min(100, currentScore))
            
            let prediction = HourlyPrediction(
                hour: hourOfDay,
                time: hourTime,
                predictedScore: Int(currentScore),
                confidence: calculateConfidence(hoursAhead: hour),
                factors: identifyHourlyFactors(
                    hourOfDay: hourOfDay,
                    naturalChange: naturalChange,
                    activityImpact: activityImpact
                )
            )
            
            predictions.append(prediction)
        }
        
        return predictions
    }
    
    // MARK: - Natural Energy Patterns
    
    private func calculateNaturalEnergyChange(
        hourOfDay: Int,
        currentScore: Double,
        sleepQuality: Int
    ) -> Double {
        
        // Natural circadian rhythm patterns
        switch hourOfDay {
        case 0...5:
            // Night/early morning - should be sleeping
            return -2.0
            
        case 6...8:
            // Morning rise
            let sleepFactor = Double(sleepQuality) / 100.0
            return 3.0 * sleepFactor
            
        case 9...11:
            // Morning peak
            return 1.0
            
        case 12...13:
            // Post-lunch dip
            return -1.5
            
        case 14...16:
            // Afternoon recovery
            return 0.5
            
        case 17...19:
            // Evening energy
            return -0.5
            
        case 20...23:
            // Night decline
            return -2.0
            
        default:
            return 0
        }
    }
    
    private func calculateActivityImpact(
        at time: Date,
        activities: [PlannedActivity]
    ) -> Double {
        
        // Find activities happening at this time
        let relevantActivities = activities.filter { activity in
            activity.startTime <= time && activity.endTime > time
        }
        
        guard !relevantActivities.isEmpty else { return 0 }
        
        // Calculate total impact
        return relevantActivities.reduce(0.0) { total, activity in
            total + activity.energyImpact
        }
    }
    
    // MARK: - Confidence Calculation
    
    private func calculateConfidence(hoursAhead: Int) -> Double {
        // Confidence decreases with time
        // 100% at hour 0, ~60% at hour 12
        let baseConfidence = 100.0
        let decayRate = 3.5 // % per hour
        
        let confidence = baseConfidence - (Double(hoursAhead) * decayRate)
        return max(50, min(100, confidence))
    }
    
    // MARK: - Factor Identification
    
    private func identifyHourlyFactors(
        hourOfDay: Int,
        naturalChange: Double,
        activityImpact: Double
    ) -> [String] {
        var factors: [String] = []
        
        // Time-based factors
        switch hourOfDay {
        case 6...8:
            factors.append("Despertar matutino")
        case 12...13:
            factors.append("Bajón post-comida")
        case 14...16:
            factors.append("Recuperación vespertina")
        case 20...23:
            factors.append("Decline natural nocturno")
        default:
            break
        }
        
        // Activity factors
        if activityImpact < -2 {
            factors.append("Actividad demandante")
        } else if activityImpact > 2 {
            factors.append("Actividad recuperativa")
        }
        
        return factors
    }
    
    // MARK: - Insights Generation
    
    private func generateInsights(
        predictions: [HourlyPrediction],
        activities: [PlannedActivity]
    ) -> [String] {
        var insights: [String] = []
        
        guard !predictions.isEmpty else { return insights }
        
        // Find peak and low points
        let sortedByScore = predictions.sorted { $0.predictedScore > $1.predictedScore }
        if let peak = sortedByScore.first, let low = sortedByScore.last {
            let peakHour = Calendar.current.component(.hour, from: peak.time)
            let lowHour = Calendar.current.component(.hour, from: low.time)
            
            insights.append("Tu pico de energía será alrededor de las \(peakHour):00 (\(peak.predictedScore)%)")
            insights.append("Tu energía más baja será alrededor de las \(lowHour):00 (\(low.predictedScore)%)")
        }
        
        // Check for critical periods
        let criticalPeriods = predictions.filter { $0.predictedScore < 30 }
        if !criticalPeriods.isEmpty {
            insights.append("⚠️ Tendrás \(criticalPeriods.count) hora(s) de energía crítica")
            insights.append("Considera programar descansos durante estos períodos")
        }
        
        // Activity recommendations
        let highEnergyPeriods = predictions.filter { $0.predictedScore >= 70 }
        if !highEnergyPeriods.isEmpty, let first = highEnergyPeriods.first {
            let hour = Calendar.current.component(.hour, from: first.time)
            insights.append("💪 Mejor momento para tareas exigentes: \(hour):00-\(hour+2):00")
        }
        
        // Check for planned activities during low energy
        for activity in activities {
            let activityHour = Calendar.current.component(.hour, from: activity.startTime)
            if let prediction = predictions.first(where: {
                Calendar.current.component(.hour, from: $0.time) == activityHour
            }), prediction.predictedScore < 40 {
                insights.append("⚠️ '\(activity.name)' está programada durante energía baja")
            }
        }
        
        return Array(insights.prefix(5))
    }
}

// MARK: - Supporting Models

struct EnergyForecast: Codable {
    let currentScore: Int
    let generatedAt: Date
    let hourlyPredictions: [HourlyPrediction]
    let insights: [String]
    
    var averagePredictedScore: Int {
        guard !hourlyPredictions.isEmpty else { return currentScore }
        let sum = hourlyPredictions.reduce(0) { $0 + $1.predictedScore }
        return sum / hourlyPredictions.count
    }
    
    var lowestPredictedScore: Int? {
        hourlyPredictions.map { $0.predictedScore }.min()
    }
    
    var highestPredictedScore: Int? {
        hourlyPredictions.map { $0.predictedScore }.max()
    }
}

struct HourlyPrediction: Codable, Identifiable {
    let id = UUID()
    let hour: Int // 0-23
    let time: Date
    let predictedScore: Int // 0-100
    let confidence: Double // 0-100
    let factors: [String]
    
    enum CodingKeys: String, CodingKey {
        case hour, time, predictedScore, confidence, factors
    }
}

struct PlannedActivity: Codable {
    let name: String
    let startTime: Date
    let endTime: Date
    let energyImpact: Double // Negative = draining, Positive = restorative
    let type: ActivityType
    
    var durationMinutes: Int {
        Int(endTime.timeIntervalSince(startTime) / 60)
    }
}

enum ActivityType: String, Codable {
    case work = "work"
    case exercise = "exercise"
    case meeting = "meeting"
    case rest = "rest"
    case social = "social"
    case meal = "meal"
    
    var defaultEnergyImpact: Double {
        switch self {
        case .work:
            return -1.5
        case .exercise:
            return -3.0 // Draining short-term, beneficial long-term
        case .meeting:
            return -2.0
        case .rest:
            return 2.0
        case .social:
            return -0.5
        case .meal:
            return 1.0
        }
    }
}

