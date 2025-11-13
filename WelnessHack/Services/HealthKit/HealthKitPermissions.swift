import Foundation
import HealthKit

struct HealthKitPermissions {
    
    // MARK: - Permission Status
    
    static func checkAuthorizationStatus() -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else {
            return false
        }
        
        let healthStore = HKHealthStore()
        
        // Check if we have authorization for key types
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let hrvType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        let stepsType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        
        let sleepStatus = healthStore.authorizationStatus(for: sleepType)
        let hrvStatus = healthStore.authorizationStatus(for: hrvType)
        let stepsStatus = healthStore.authorizationStatus(for: stepsType)
        
        return sleepStatus == .sharingAuthorized &&
               hrvStatus == .sharingAuthorized &&
               stepsStatus == .sharingAuthorized
    }
    
    // MARK: - Required Types
    
    static var readTypes: Set<HKObjectType> {
        return [
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
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
        ]
    }
    
    static var writeTypes: Set<HKSampleType> {
        return [
            // We might write custom data in the future
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]
    }
    
    // MARK: - Permission Descriptions
    
    static func getPermissionDescription(for identifier: HKQuantityTypeIdentifier) -> String {
        switch identifier {
        case .heartRateVariabilitySDNN:
            return "HRV (Variabilidad Cardíaca) - Para medir tu recuperación y estrés"
        case .heartRate:
            return "Frecuencia Cardíaca - Para monitorear tu actividad cardiovascular"
        case .restingHeartRate:
            return "Frecuencia Cardíaca en Reposo - Indicador de tu condición física"
        case .stepCount:
            return "Pasos - Para medir tu actividad diaria"
        case .activeEnergyBurned:
            return "Calorías Activas - Para calcular tu gasto energético"
        case .appleExerciseTime:
            return "Minutos de Ejercicio - Para rastrear tu actividad física"
        case .distanceWalkingRunning:
            return "Distancia Caminada/Corrida - Para medir tu movimiento"
        default:
            return "Datos de Salud"
        }
    }
    
    static func getCategoryDescription(for identifier: HKCategoryTypeIdentifier) -> String {
        switch identifier {
        case .sleepAnalysis:
            return "Análisis de Sueño - Para evaluar tu calidad de descanso"
        default:
            return "Datos de Salud"
        }
    }
}

