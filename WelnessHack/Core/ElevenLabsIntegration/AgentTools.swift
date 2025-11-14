import Foundation

@MainActor
class AgentToolHandler {
    
    private let healthKitManager = HealthKitManager.shared
    private let bodyBatteryCalculator = BodyBatteryCalculator()
    private let bodyBatteryPredictor = BodyBatteryPredictor()
    
    // MARK: - Tool: get_current_energy_score
    
    func getCurrentEnergyScore() async throws -> [String: Any] {
        // Fetch latest health data (handle missing data gracefully)
        let sleepData = try? await healthKitManager.fetchLastNightSleep()
        let hrvAverage = try? await healthKitManager.fetchAverageHRV()
        let activityData = try? await healthKitManager.fetchActivitySummary()
        
        // Calculate body battery (works even with nil values)
        let snapshot = bodyBatteryCalculator.calculateBodyBattery(
            sleepData: sleepData,
            hrvAverage: hrvAverage,
            activityData: activityData
        )
        
        return [
            "score": snapshot.score,
            "level": snapshot.scoreLevel.rawValue,
            "emoji": snapshot.emoji,
            "factors": snapshot.factors,
            "recommendations": snapshot.recommendations,
            "components": [
                "sleep": snapshot.sleepScore,
                "hrv": snapshot.hrvScore,
                "activity": snapshot.activityScore
            ],
            "metadata": [
                "sleep_hours": sleepData?.durationHours ?? 0,
                "hrv_average": hrvAverage ?? 0,
                "activity_level": activityData?.intensity.rawValue ?? "unknown",
                "has_sleep_data": sleepData != nil,
                "has_hrv_data": hrvAverage != nil,
                "has_activity_data": activityData != nil
            ]
        ]
    }
    
    // MARK: - Tool: get_energy_forecast
    
    func getEnergyForecast(hours: Int = 6) async throws -> [String: Any] {
        // Get current score first
        let currentScoreData = try await getCurrentEnergyScore()
        guard let currentScore = currentScoreData["score"] as? Int else {
            throw ElevenLabsError.toolExecutionFailed("get_energy_forecast")
        }
        
        // Get sleep data for forecast (handle missing data)
        let sleepData = try? await healthKitManager.fetchLastNightSleep()
        
        // Generate forecast
        let forecast = bodyBatteryPredictor.generateForecast(
            currentScore: currentScore,
            hoursAhead: hours,
            sleepData: sleepData
        )
        
        return [
            "current_score": forecast.currentScore,
            "hours_ahead": hours,
            "average_predicted": forecast.averagePredictedScore,
            "lowest_predicted": forecast.lowestPredictedScore ?? 0,
            "highest_predicted": forecast.highestPredictedScore ?? 0,
            "insights": forecast.insights,
            "hourly_predictions": forecast.hourlyPredictions.map { prediction in
                [
                    "hour": prediction.hour,
                    "score": prediction.predictedScore,
                    "confidence": prediction.confidence,
                    "factors": prediction.factors
                ]
            }
        ]
    }
    
    // MARK: - Tool: get_sleep_analysis
    
    func getSleepAnalysis() async throws -> [String: Any] {
        guard let sleepData = try? await healthKitManager.fetchLastNightSleep() else {
            return [
                "error": "No hay datos de sueño disponibles",
                "message": "No se encontraron datos de sueño en HealthKit. Asegúrate de usar un dispositivo con datos de sueño o Apple Watch."
            ]
        }
        
        let bedTimeStr = sleepData.bedTime?.formatted(date: .omitted, time: .shortened) ?? "N/A"
        let wakeTimeStr = sleepData.wakeTime?.formatted(date: .omitted, time: .shortened) ?? "N/A"
        
        var analysis: [String] = []
        
        // Duration analysis
        if sleepData.durationHours < 6 {
            analysis.append("Duración insuficiente - Necesitas más descanso")
        } else if sleepData.durationHours >= 7 && sleepData.durationHours <= 9 {
            analysis.append("Duración óptima - Excelente")
        } else if sleepData.durationHours > 9 {
            analysis.append("Duración larga - Puede indicar recuperación o fatiga acumulada")
        }
        
        // Deep sleep analysis
        if sleepData.deepSleepPercentage < 10 {
            analysis.append("Poco sueño profundo - Intenta reducir estrés y cafeína")
        } else if sleepData.deepSleepPercentage >= 15 && sleepData.deepSleepPercentage <= 25 {
            analysis.append("Sueño profundo óptimo - Excelente recuperación")
        }
        
        // Awake time analysis
        let awakeMinutes = Int(sleepData.awakeDuration / 60)
        if awakeMinutes > 30 {
            analysis.append("Despertares frecuentes - Considera mejorar ambiente de sueño")
        } else if awakeMinutes < 15 {
            analysis.append("Sueño continuo - Muy bueno")
        }
        
        return [
            "duration": sleepData.duration,
            "duration_hours": sleepData.durationHours,
            "quality": sleepData.quality,
            "deep_sleep_percentage": sleepData.deepSleepPercentage,
            "deep_sleep_hours": sleepData.deepSleepDuration / 3600,
            "rem_sleep_hours": sleepData.remSleepDuration / 3600,
            "awake_minutes": awakeMinutes,
            "bed_time": bedTimeStr,
            "wake_time": wakeTimeStr,
            "analysis": analysis,
            "rating": getSleepRating(quality: sleepData.quality)
        ]
    }
    
    // MARK: - Tool: get_activity_summary
    
    func getActivitySummary() async throws -> [String: Any] {
        guard let activityData = try? await healthKitManager.fetchActivitySummary() else {
            return [
                "error": "No hay datos de actividad disponibles",
                "message": "No se encontraron datos de actividad en HealthKit."
            ]
        }
        
        var insights: [String] = []
        
        // Steps analysis
        if activityData.steps < 5000 {
            insights.append("Actividad baja - Intenta caminar más")
        } else if activityData.steps >= 10000 {
            insights.append("Excelente nivel de pasos - ¡Sigue así!")
        }
        
        // Exercise analysis
        if activityData.exerciseMinutes >= 30 {
            insights.append("Cumpliste la meta de ejercicio diario")
        } else if activityData.exerciseMinutes > 0 {
            insights.append("Algo de ejercicio es mejor que nada")
        }
        
        // Intensity analysis
        switch activityData.intensity {
        case .sedentary:
            insights.append("Día sedentario - Considera actividad ligera")
        case .light:
            insights.append("Actividad ligera - Bueno para recuperación")
        case .moderate:
            insights.append("Actividad moderada - Balance saludable")
        case .high:
            insights.append("Actividad intensa - Asegúrate de recuperar bien")
        }
        
        return [
            "steps": activityData.steps,
            "active_calories": activityData.activeCalories,
            "exercise_minutes": activityData.exerciseMinutes,
            "distance_km": activityData.distanceKm,
            "intensity": activityData.intensity.rawValue,
            "resting_heart_rate": activityData.restingHeartRate ?? 0,
            "insights": insights,
            "goals_met": [
                "steps_goal": activityData.steps >= 10000,
                "exercise_goal": activityData.exerciseMinutes >= 30,
                "calories_goal": activityData.activeCalories >= 400
            ]
        ]
    }
    
    // MARK: - Tool: recommend_actions
    
    func recommendActions(context: String = "") async throws -> [String: Any] {
        // Get current state
        let energyData = try await getCurrentEnergyScore()
        guard let score = energyData["score"] as? Int else {
            throw ElevenLabsError.toolExecutionFailed("recommend_actions")
        }
        
        let sleepData = try await healthKitManager.fetchLastNightSleep()
        let activityData = try await healthKitManager.fetchActivitySummary()
        
        var recommendations: [String] = []
        var priority: String
        
        // Context-aware recommendations
        let lowerContext = context.lowercased()
        
        if lowerContext.contains("cansado") || lowerContext.contains("agotado") {
            recommendations.append("🛋️ Toma un descanso de 10-15 minutos")
            recommendations.append("💧 Hidrátate - A veces la fatiga es deshidratación")
            recommendations.append("🚶 Caminata corta al aire libre puede ayudar")
        } else if lowerContext.contains("reunión") || lowerContext.contains("presentación") {
            if score < 50 {
                recommendations.append("☕ Considera cafeína estratégica 30min antes")
                recommendations.append("🧘 Respiración profunda 5 minutos antes")
            } else {
                recommendations.append("✅ Tu energía es buena para la reunión")
            }
        } else if lowerContext.contains("ejercicio") || lowerContext.contains("entrenar") {
            if score >= 70 {
                recommendations.append("💪 Excelente momento para entrenar")
                recommendations.append("🏋️ Puedes hacer intensidad alta")
            } else if score >= 50 {
                recommendations.append("🚴 Ejercicio moderado es apropiado")
                recommendations.append("⚠️ Evita intensidad muy alta")
            } else {
                recommendations.append("🚶 Mejor solo actividad ligera hoy")
                recommendations.append("🧘 Yoga o estiramiento es ideal")
            }
        }
        
        // General recommendations based on score
        if score < 30 {
            priority = "high"
            recommendations.append("🚨 Prioridad: Descanso inmediato")
            recommendations.append("🛌 Considera siesta de 20-30 minutos")
            recommendations.append("❌ Evita decisiones importantes")
        } else if score < 50 {
            priority = "medium"
            recommendations.append("⚠️ Energía baja - Gestiona carga")
            recommendations.append("📋 Tareas simples y rutinarias")
            recommendations.append("⏰ Planifica descansos frecuentes")
        } else if score < 75 {
            priority = "low"
            recommendations.append("✅ Energía estable")
            recommendations.append("📊 Puedes hacer tareas moderadas")
            recommendations.append("🎯 Buen momento para trabajo enfocado")
        } else {
            priority = "optimal"
            recommendations.append("⚡ Energía óptima")
            recommendations.append("🚀 Aprovecha para tareas exigentes")
            recommendations.append("💡 Momento ideal para creatividad")
        }
        
        // Sleep-based recommendations
        if sleepData.durationHours < 7 {
            recommendations.append("🌙 Prioriza dormir 7-9h esta noche")
        }
        
        // Activity-based recommendations
        if activityData.intensity == .sedentary {
            recommendations.append("🚶 Intenta caminar 10 minutos cada hora")
        }
        
        return [
            "recommendations": Array(recommendations.prefix(5)),
            "priority": priority,
            "current_score": score,
            "context_considered": !context.isEmpty,
            "next_check_in": "2 hours"
        ]
    }
    
    // MARK: - Helper Methods
    
    private func getSleepRating(quality: Int) -> String {
        switch quality {
        case 0..<40:
            return "Pobre"
        case 40..<60:
            return "Regular"
        case 60..<80:
            return "Bueno"
        case 80...100:
            return "Excelente"
        default:
            return "N/A"
        }
    }
}

