# Onboarding Conversacional - Implementación

## 📋 Descripción General

Sistema de onboarding conversacional guiado por IA que recopila información del usuario a través de una conversación natural por voz, en lugar de un formulario tradicional.

---

## 🎯 Objetivos

1. **Experiencia Natural**: Conversación fluida y natural, no un formulario
2. **Personalización**: Recopilar información clave para personalizar la experiencia
3. **Empatía**: Crear conexión emocional desde el primer contacto
4. **Eficiencia**: Completar en 3-5 minutos
5. **Flexibilidad**: Permitir que el usuario omita información si lo desea

---

## 🏗️ Arquitectura

### Componentes Principales

```
┌─────────────────────────────────────────────────────────────┐
│                      VapiChatScreen                         │
│  - Detecta primera vez                                      │
│  - Muestra indicador de onboarding                          │
│  - Inicia conversación con contexto especial                │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                   VapiChatViewModel                         │
│  - checkOnboardingStatus()                                  │
│  - startChatSession() → detecta onboarding                  │
│  - completeOnboarding()                                     │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                   OnboardingManager                         │
│  - Singleton que maneja el estado                           │
│  - Guarda/carga UserProfile                                 │
│  - Proporciona prompts para cada paso                       │
│  - Marca onboarding como completo                           │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      UserProfile                            │
│  - Modelo de datos del usuario                              │
│  - Guardado en UserDefaults                                 │
│  - Incluye goals, health info, preferences                  │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                  ConversationContext                        │
│  - createForOnboarding()                                    │
│  - Contexto especial para el agente                         │
│  - Indica que es primera vez                                │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                   ElevenLabs Agent                          │
│  - Recibe contexto de onboarding                            │
│  - Sigue el prompt conversacional                           │
│  - Hace preguntas una a la vez                              │
│  - Guarda respuestas del usuario                            │
└─────────────────────────────────────────────────────────────┘
```

---

## 📊 Flujo de Onboarding

### Paso 1: Detección de Primera Vez

```swift
// En VapiChatViewModel.init()
private func checkOnboardingStatus() {
    isOnboarding = !onboardingManager.isOnboardingComplete
    if isOnboarding {
        onboardingMessage = onboardingManager.getOnboardingPrompt()
        print("👋 Usuario nuevo - Onboarding requerido")
    }
}
```

### Paso 2: Inicio de Conversación

```swift
// En VapiChatViewModel.startChatSession()
if !onboardingManager.isOnboardingComplete {
    // Modo onboarding
    context = ConversationContext.createForOnboarding()
    isOnboarding = true
    onboardingMessage = onboardingManager.getOnboardingPrompt()
} else {
    // Modo normal
    context = await ConversationContext.create(from: bodyBattery, ...)
}
```

### Paso 3: Conversación Guiada

El agente de ElevenLabs sigue este flujo:

1. **Bienvenida** → "¿Cómo te llamas?"
2. **Edad** → "¿Cuántos años tienes?"
3. **Objetivo** → "¿Cuál es tu objetivo principal?"
4. **Energía** → "¿Cómo está tu nivel de energía?"
5. **Sueño** → "¿Cómo has dormido?"
6. **Estrés** → "¿Cómo está tu nivel de estrés?"
7. **Actividad** → "¿Qué tan activo eres?"
8. **Salud** → "¿Alguna condición de salud?"
9. **Resumen** → Confirma toda la información
10. **Completado** → "¡Listo para empezar!"

### Paso 4: Guardado de Datos

```swift
// Durante la conversación, el agente llama a client tools
// que actualizan el UserProfile a través del OnboardingManager

onboardingManager.updateProfile { profile in
    profile.name = "Juan"
    profile.primaryGoal = .increaseEnergy
    profile.currentEnergyLevel = .low
    // ... etc
}
```

### Paso 5: Completación

```swift
// Cuando el agente termina el onboarding
viewModel.completeOnboarding()

// Esto marca el perfil como completo
onboardingManager.completeOnboarding()
```

---

## 💾 Modelo de Datos

### UserProfile

```swift
struct UserProfile: Codable {
    // Basic Info
    var name: String?
    var age: Int?
    
    // Wellness Goals
    var primaryGoal: WellnessGoal?
    var secondaryGoals: [WellnessGoal] = []
    
    // Health Context
    var currentEnergyLevel: EnergyLevel?
    var sleepQuality: SleepQuality?
    var stressLevel: StressLevel?
    var activityLevel: ActivityLevel?
    
    // Health Conditions
    var healthConditions: [String] = []
    var medications: [String] = []
    
    // Onboarding State
    var onboardingCompleted: Bool = false
    var onboardingDate: Date?
}
```

### Enums de Wellness

```swift
enum WellnessGoal: String, Codable {
    case improveSleep = "improve_sleep"
    case increaseEnergy = "increase_energy"
    case reduceStress = "reduce_stress"
    case betterFocus = "better_focus"
    case moreActive = "more_active"
    case balanceLife = "balance_life"
    case betterMood = "better_mood"
}

enum EnergyLevel: String, Codable {
    case veryLow, low, moderate, high, veryHigh
}

enum SleepQuality: String, Codable {
    case veryPoor, poor, fair, good, excellent
}

enum StressLevel: String, Codable {
    case minimal, low, moderate, high, veryHigh
}

enum ActivityLevel: String, Codable {
    case sedentary, lightlyActive, moderatelyActive
    case veryActive, extremelyActive
}
```

---

## 🎨 UI/UX

### Indicador Visual

Cuando el usuario no ha completado el onboarding:

```swift
VStack(spacing: 8) {
    Text("👋 Primera vez")
        .font(.caption)
        .fontWeight(.semibold)
        .foregroundColor(.appAccent)
    
    Text("Toca para comenzar tu onboarding")
        .font(.caption2)
        .foregroundColor(.white.opacity(0.7))
}
```

### Estado de Conexión

Durante el onboarding:
```
"Onboarding - Habla conmigo"
```

Después del onboarding:
```
"Conectado - Habla ahora"
```

---

## 🔧 Configuración del Agente

### En ElevenLabs Dashboard:

1. **System Prompt**: Usar el prompt de `ONBOARDING_AGENT_PROMPT.md`
2. **Language**: Spanish (es)
3. **Voice**: Voz cálida y profesional
4. **Temperature**: 0.7-0.8 para naturalidad

### Client Tools Requeridas:

```javascript
// 1. Guardar datos de onboarding
{
  "name": "save_onboarding_data",
  "description": "Guarda información del usuario durante el onboarding",
  "parameters": {
    "name": "string",
    "age": "number",
    "primary_goal": "string",
    "energy_level": "string",
    "sleep_quality": "string",
    "stress_level": "string",
    "activity_level": "string",
    "health_conditions": "array"
  }
}

// 2. Completar onboarding
{
  "name": "complete_onboarding",
  "description": "Marca el onboarding como completado",
  "parameters": {}
}
```

---

## 🧪 Testing

### Casos de Prueba:

1. **Happy Path**: Usuario completa todo el onboarding
2. **Información Parcial**: Usuario omite algunas preguntas
3. **Usuario Tímido**: No quiere compartir información personal
4. **Usuario Distraído**: Se desvía del tema
5. **Interrupción**: Usuario cierra la app a mitad del onboarding

### Comandos de Testing:

```swift
// Resetear onboarding para testing
viewModel.resetOnboarding()

// Verificar estado
print(onboardingManager.isOnboardingComplete)
print(onboardingManager.userProfile)

// Ver progreso
print(onboardingManager.getProfileCompletion()) // 0.0 - 1.0
```

---

## 📈 Métricas

### KPIs a Monitorear:

1. **Tasa de Completación**: % de usuarios que completan el onboarding
2. **Tiempo Promedio**: Duración del onboarding
3. **Tasa de Abandono**: En qué paso abandonan
4. **Calidad de Datos**: % de campos completados
5. **Satisfacción**: Feedback del usuario

### Objetivos:

- ✅ Completación > 80%
- ✅ Tiempo: 3-5 minutos
- ✅ Abandono < 20%
- ✅ Datos completos > 70%

---

## 🚀 Próximos Pasos

### Mejoras Futuras:

1. **Onboarding Progresivo**: Recopilar más información con el tiempo
2. **Re-onboarding**: Actualizar información periódicamente
3. **Personalización del Prompt**: Ajustar según el objetivo del usuario
4. **Analytics**: Tracking detallado del flujo
5. **A/B Testing**: Probar diferentes enfoques conversacionales

### Integraciones:

1. **HealthKit**: Importar datos automáticamente si están disponibles
2. **Cloud Sync**: Sincronizar perfil entre dispositivos
3. **Backend**: Guardar en servidor para análisis
4. **Notificaciones**: Recordatorio si no completa el onboarding

---

## 📝 Notas de Implementación

### Persistencia:

- Los datos se guardan en `UserDefaults` con la key `"user_profile"`
- El estado de completación se guarda en `"onboarding_complete"`
- Los datos se codifican como JSON usando `Codable`

### Seguridad:

- Los datos son locales y no se envían a ningún servidor (por ahora)
- La información de salud es sensible y debe manejarse con cuidado
- Considerar encriptación para datos sensibles en el futuro

### Performance:

- El `OnboardingManager` es un singleton para evitar múltiples instancias
- Los datos se cargan una vez al inicio
- Las actualizaciones son inmediatas y se guardan automáticamente

---

## 🐛 Troubleshooting

### Problema: El onboarding no se detecta

**Solución**: Verificar que `OnboardingManager.shared.isOnboardingComplete` sea `false`

### Problema: Los datos no se guardan

**Solución**: Verificar que `saveProfile()` se llame después de cada actualización

### Problema: El agente no sigue el flujo

**Solución**: Revisar el system prompt en ElevenLabs Dashboard

### Problema: El usuario quiere reiniciar el onboarding

**Solución**: Llamar a `viewModel.resetOnboarding()`

---

## 📚 Referencias

- `UserProfile.swift` - Modelo de datos
- `OnboardingManager.swift` - Lógica de negocio
- `VapiChatViewModel.swift` - Integración con UI
- `ConversationContext.swift` - Contexto para el agente
- `ONBOARDING_AGENT_PROMPT.md` - Prompt del agente
