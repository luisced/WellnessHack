import Foundation

@MainActor
class BodyBatteryCalculator {
    
    // MARK: - Main Calculation
    
    func calculateBodyBattery(
        sleepData: SleepData?,
        hrvAverage: Double?,
        activityData: ActivityData?
    ) -> BodyBatterySnapshot {
        
        let sleepScore = calculateSleepScore(from: sleepData)
        let hrvScore = calculateHRVScore(from: hrvAverage)
        let activityScore = calculateActivityScore(from: activityData)
        
        // Weighted average: Sleep 50%, HRV 30%, Activity 20%
        let totalScore = Int(
            (Double(sleepScore) * 0.5) +
            (Double(hrvScore) * 0.3) +
            (Double(activityScore) * 0.2)
        )
        
        let factors = identifyFactors(
            sleepScore: sleepScore,
            hrvScore: hrvScore,
            activityScore: activityScore,
            sleepData: sleepData,
            hrvAverage: hrvAverage,
            activityData: activityData
        )
        
        let recommendations = generateRecommendations(
            score: totalScore,
            factors: factors,
            sleepData: sleepData,
            activityData: activityData
        )
        
        return BodyBatterySnapshot(
            score: max(0, min(100, totalScore)),
            sleepScore: sleepScore,
            hrvScore: hrvScore,
            activityScore: activityScore,
            factors: factors,
            recommendations: recommendations,
            sleepDuration: sleepData?.duration,
            hrvAverage: hrvAverage,
            activityLevel: activityData?.intensity.rawValue
        )
    }
    
    // MARK: - Component Scores
    
    private func calculateSleepScore(from sleepData: SleepData?) -> Int {
        guard let sleep = sleepData else { return 50 } // Default if no data
        
        let hoursSlept = sleep.durationHours
        
        // Duration score (0-40 points)
        // Optimal: 7-9 hours
        let durationScore: Double
        if hoursSlept >= 7 && hoursSlept <= 9 {
            durationScore = 40
        } else if hoursSlept >= 6 && hoursSlept < 7 {
            durationScore = 30
        } else if hoursSlept >= 5 && hoursSlept < 6 {
            durationScore = 20
        } else if hoursSlept < 5 {
            durationScore = 10
        } else { // > 9 hours
            durationScore = 35
        }
        
        // Deep sleep score (0-40 points)
        // Optimal: 15-25% deep sleep
        let deepPercentage = sleep.deepSleepPercentage
        let deepScore: Double
        if deepPercentage >= 15 && deepPercentage <= 25 {
            deepScore = 40
        } else if deepPercentage >= 10 && deepPercentage < 15 {
            deepScore = 30
        } else if deepPercentage >= 5 && deepPercentage < 10 {
            deepScore = 20
        } else {
            deepScore = 10
        }
        
        // Awake time penalty (0-20 points)
        let awakeMinutes = sleep.awakeDuration / 60
        let awakeScore: Double
        if awakeMinutes < 15 {
            awakeScore = 20
        } else if awakeMinutes < 30 {
            awakeScore = 15
        } else if awakeMinutes < 45 {
            awakeScore = 10
        } else {
            awakeScore = 5
        }
        
        return Int(durationScore + deepScore + awakeScore)
    }
    
    private func calculateHRVScore(from hrvAverage: Double?) -> Int {
        guard let hrv = hrvAverage else { return 50 } // Default if no data
        
        // HRV scoring (higher is better)
        // Typical ranges:
        // Excellent: > 60ms
        // Good: 40-60ms
        // Fair: 20-40ms
        // Poor: < 20ms
        
        if hrv >= 60 {
            return 100
        } else if hrv >= 50 {
            return 85
        } else if hrv >= 40 {
            return 70
        } else if hrv >= 30 {
            return 55
        } else if hrv >= 20 {
            return 40
        } else {
            return 25
        }
    }
    
    private func calculateActivityScore(from activityData: ActivityData?) -> Int {
        guard let activity = activityData else { return 50 } // Default if no data
        
        // Activity can both drain and restore energy
        // Light activity = recovery (+)
        // Moderate activity = neutral
        // High activity = draining (-)
        
        let baseScore = 50
        
        switch activity.intensity {
        case .sedentary:
            // Too sedentary can be negative
            return max(30, baseScore - 10)
            
        case .light:
            // Light activity is restorative
            return min(80, baseScore + 20)
            
        case .moderate:
            // Moderate is neutral to slightly positive
            if activity.exerciseMinutes >= 30 {
                return min(70, baseScore + 10)
            } else {
                return baseScore
            }
            
        case .high:
            // High intensity drains energy (but is good long-term)
            if activity.exerciseMinutes >= 60 {
                return max(20, baseScore - 30)
            } else {
                return max(30, baseScore - 20)
            }
        }
    }
    
    // MARK: - Factors Identification
    
    private func identifyFactors(
        sleepScore: Int,
        hrvScore: Int,
        activityScore: Int,
        sleepData: SleepData?,
        hrvAverage: Double?,
        activityData: ActivityData?
    ) -> [String] {
        var factors: [String] = []
        
        // Sleep factors
        if let sleep = sleepData {
            if sleep.durationHours < 6 {
                factors.append("Sueño insuficiente (\(String(format: "%.1f", sleep.durationHours))h)")
            } else if sleep.durationHours >= 8 {
                factors.append("Buen descanso (\(String(format: "%.1f", sleep.durationHours))h)")
            }
            
            if sleep.deepSleepPercentage < 10 {
                factors.append("Poco sueño profundo (\(String(format: "%.0f", sleep.deepSleepPercentage))%)")
            } else if sleep.deepSleepPercentage >= 20 {
                factors.append("Excelente sueño profundo (\(String(format: "%.0f", sleep.deepSleepPercentage))%)")
            }
            
            if sleep.awakeDuration / 60 > 30 {
                factors.append("Despertares frecuentes")
            }
        }
        
        // HRV factors
        if let hrv = hrvAverage {
            if hrv < 30 {
                factors.append("HRV bajo - Alto estrés")
            } else if hrv >= 50 {
                factors.append("HRV excelente - Buena recuperación")
            }
        }
        
        // Activity factors
        if let activity = activityData {
            switch activity.intensity {
            case .sedentary:
                factors.append("Actividad muy baja")
            case .light:
                factors.append("Actividad ligera - Recuperación activa")
            case .moderate:
                factors.append("Actividad moderada")
            case .high:
                factors.append("Actividad intensa - Necesitas recuperación")
            }
            
            if activity.exerciseMinutes >= 60 {
                factors.append("Entrenamiento intenso (\(activity.exerciseMinutes) min)")
            }
        }
        
        return factors
    }
    
    // MARK: - Recommendations
    
    private func generateRecommendations(
        score: Int,
        factors: [String],
        sleepData: SleepData?,
        activityData: ActivityData?
    ) -> [String] {
        var recommendations: [String] = []
        
        // Score-based recommendations
        if score < 25 {
            recommendations.append("🛑 Prioriza descanso - Evita actividades demandantes")
            recommendations.append("💤 Considera una siesta de 20-30 minutos")
        } else if score < 50 {
            recommendations.append("⚠️ Energía baja - Planifica tareas ligeras")
            recommendations.append("🚶 Caminata suave puede ayudar")
        } else if score < 75 {
            recommendations.append("✅ Energía estable - Buen momento para tareas moderadas")
            recommendations.append("💪 Puedes hacer ejercicio ligero a moderado")
        } else {
            recommendations.append("⚡ Excelente energía - Aprovecha para tareas importantes")
            recommendations.append("🎯 Momento ideal para entrenamientos intensos")
        }
        
        // Sleep-based recommendations
        if let sleep = sleepData {
            if sleep.durationHours < 7 {
                recommendations.append("🌙 Intenta dormir 7-9 horas esta noche")
            }
            
            if sleep.deepSleepPercentage < 15 {
                recommendations.append("🧘 Evita cafeína 6h antes de dormir")
                recommendations.append("📱 Reduce pantallas 1h antes de dormir")
            }
        }
        
        // Activity-based recommendations
        if let activity = activityData {
            if activity.intensity == .sedentary {
                recommendations.append("🚶 Intenta caminar 10,000 pasos hoy")
            } else if activity.intensity == .high && activity.exerciseMinutes >= 60 {
                recommendations.append("🛀 Considera un día de recuperación activa")
                recommendations.append("💧 Hidrátate bien después del entrenamiento")
            }
        }
        
        return Array(recommendations.prefix(4)) // Limit to 4 recommendations
    }
}

