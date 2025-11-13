# ElevenLabs Agent Setup Guide

## Paso 1: Crear Cuenta en ElevenLabs

1. Ve a [https://elevenlabs.io](https://elevenlabs.io)
2. Crea una cuenta o inicia sesión
3. Ve al dashboard de Agents: [https://elevenlabs.io/app/conversational-ai](https://elevenlabs.io/app/conversational-ai)

## Paso 2: Crear un Nuevo Agente

1. Click en "Create Agent" o "New Agent"
2. Configura los siguientes parámetros:

### Configuración Básica

**Name**: Energy Coach  
**Language**: Spanish (Español)  
**Voice**: Selecciona una voz en español que suene amigable y motivadora

### System Prompt

```
Eres un coach de bienestar personal especializado en energía y recuperación.

Tu objetivo es ayudar al usuario a:
- Entender su nivel de energía actual (Body Battery 0-100)
- Comprender qué factores afectan su energía (sueño, HRV, actividad)
- Recibir pronósticos de energía para el día
- Obtener recomendaciones personalizadas

Datos disponibles a través de herramientas:
- Body Battery score (0-100) con componentes de sueño, HRV y actividad
- Calidad de sueño de anoche con análisis detallado
- HRV (variabilidad cardíaca) promedio
- Actividad física del día (pasos, calorías, ejercicio)
- Pronósticos de energía para próximas horas
- Recomendaciones personalizadas basadas en contexto

Herramientas disponibles:
- get_current_energy_score: Obtiene score actual con factores y recomendaciones
- get_energy_forecast: Pronóstico de energía para próximas horas
- get_sleep_analysis: Análisis detallado de sueño de anoche
- get_activity_summary: Resumen de actividad física del día
- recommend_actions: Recomendaciones personalizadas basadas en contexto

Estilo de conversación:
- Amigable y motivador, nunca crítico
- Basado en datos reales de HealthKit
- Conciso pero informativo (respuestas de 2-3 frases)
- Proactivo con recomendaciones
- Usa emojis ocasionalmente para hacer la conversación más amigable
- Habla en español de forma natural y cercana

Ejemplos de interacción:

Usuario: "¿Cómo está mi energía?"
Tú: "Tu energía está en 72/100 - nivel moderado ⚡. Dormiste bien anoche (7.5 horas) y tu HRV está estable. Es buen momento para tareas que requieren concentración."

Usuario: "¿Debería hacer ejercicio?"
Tú: "Con tu energía actual de 68/100, ejercicio moderado es perfecto 💪. Tu cuerpo está recuperado del sueño. Te recomiendo 30-45 minutos de cardio ligero o entrenamiento de fuerza."

Usuario: "Me siento cansado"
Tú: "Entiendo. Déjame revisar tus datos... [llama get_current_energy_score]. Tu energía está en 42/100 - un poco baja. Factores: solo 5.5 horas de sueño anoche. Te recomiendo: tomar un descanso de 15 minutos, hidratarte, y evitar tareas muy demandantes por ahora."
```

## Paso 3: Configurar Client Tools

En la sección de "Tools" o "Functions" del agente, agrega las siguientes herramientas:

### Tool 1: get_current_energy_score

```json
{
  "type": "client_tool",
  "name": "get_current_energy_score",
  "description": "Obtiene el score de energía actual del usuario (Body Battery 0-100) con factores que lo afectan y recomendaciones personalizadas. Incluye componentes individuales de sueño, HRV y actividad.",
  "parameters": {
    "type": "object",
    "properties": {},
    "required": []
  }
}
```

**Respuesta esperada**:
```json
{
  "score": 72,
  "level": "moderate",
  "emoji": "🟢",
  "factors": ["Buen descanso (7.5h)", "HRV estable"],
  "recommendations": ["Momento ideal para tareas importantes", "Puedes hacer ejercicio moderado"],
  "components": {
    "sleep": 80,
    "hrv": 70,
    "activity": 60
  },
  "metadata": {
    "sleep_hours": 7.5,
    "hrv_average": 65,
    "activity_level": "moderate"
  }
}
```

### Tool 2: get_energy_forecast

```json
{
  "type": "client_tool",
  "name": "get_energy_forecast",
  "description": "Genera un pronóstico de energía para las próximas horas basado en patrones circadianos, calidad de sueño y actividades planificadas",
  "parameters": {
    "type": "object",
    "properties": {
      "hours": {
        "type": "number",
        "description": "Número de horas para el pronóstico (1-12)",
        "minimum": 1,
        "maximum": 12
      }
    },
    "required": ["hours"]
  }
}
```

**Respuesta esperada**:
```json
{
  "current_score": 72,
  "hours_ahead": 6,
  "average_predicted": 65,
  "lowest_predicted": 55,
  "highest_predicted": 75,
  "insights": [
    "Tu pico de energía será alrededor de las 10:00 (75%)",
    "Tu energía más baja será alrededor de las 14:00 (55%)",
    "💪 Mejor momento para tareas exigentes: 10:00-12:00"
  ],
  "hourly_predictions": [...]
}
```

### Tool 3: get_sleep_analysis

```json
{
  "type": "client_tool",
  "name": "get_sleep_analysis",
  "description": "Obtiene análisis detallado de la última noche de sueño incluyendo duración, calidad, sueño profundo, REM, y recomendaciones",
  "parameters": {
    "type": "object",
    "properties": {},
    "required": []
  }
}
```

**Respuesta esperada**:
```json
{
  "duration": 27000,
  "duration_hours": 7.5,
  "quality": 80,
  "deep_sleep_percentage": 18.5,
  "deep_sleep_hours": 1.4,
  "rem_sleep_hours": 1.5,
  "awake_minutes": 15,
  "bed_time": "23:30",
  "wake_time": "07:00",
  "analysis": [
    "Duración óptima - Excelente",
    "Sueño profundo óptimo - Excelente recuperación",
    "Sueño continuo - Muy bueno"
  ],
  "rating": "Excelente"
}
```

### Tool 4: get_activity_summary

```json
{
  "type": "client_tool",
  "name": "get_activity_summary",
  "description": "Obtiene resumen de actividad física del día incluyendo pasos, calorías, minutos de ejercicio y nivel de intensidad",
  "parameters": {
    "type": "object",
    "properties": {},
    "required": []
  }
}
```

**Respuesta esperada**:
```json
{
  "steps": 8500,
  "active_calories": 450,
  "exercise_minutes": 35,
  "distance_km": 6.5,
  "intensity": "moderate",
  "resting_heart_rate": 62,
  "insights": [
    "Algo de ejercicio es mejor que nada",
    "Actividad moderada - Balance saludable"
  ],
  "goals_met": {
    "steps_goal": false,
    "exercise_goal": true,
    "calories_goal": true
  }
}
```

### Tool 5: recommend_actions

```json
{
  "type": "client_tool",
  "name": "recommend_actions",
  "description": "Genera recomendaciones personalizadas basadas en el nivel de energía actual y contexto específico del usuario (ej: reunión importante, quiere hacer ejercicio, se siente cansado)",
  "parameters": {
    "type": "object",
    "properties": {
      "context": {
        "type": "string",
        "description": "Contexto adicional del usuario (ej: 'tengo reunión importante', 'me siento cansado', 'quiero entrenar')"
      }
    },
    "required": []
  }
}
```

**Respuesta esperada**:
```json
{
  "recommendations": [
    "🛋️ Toma un descanso de 10-15 minutos",
    "💧 Hidrátate - A veces la fatiga es deshidratación",
    "🚶 Caminata corta al aire libre puede ayudar"
  ],
  "priority": "medium",
  "current_score": 42,
  "context_considered": true,
  "next_check_in": "2 hours"
}
```

## Paso 4: Configurar Variables de Entorno

Una vez creado el agente, necesitas configurar las variables de entorno en tu proyecto:

### Obtener Agent ID
1. En el dashboard de ElevenLabs, ve a tu agente
2. Copia el Agent ID (formato: `agent_xxxxxxxxxxxxx`)

### Obtener API Key
1. Ve a Settings → API Keys
2. Crea una nueva API key o copia una existente
3. **IMPORTANTE**: Guarda esta key de forma segura, no la compartas

### Configurar en Xcode

**Opción 1: Scheme Environment Variables (Recomendado para desarrollo)**

1. En Xcode, ve a Product → Scheme → Edit Scheme
2. Selecciona "Run" en el sidebar
3. Ve a la pestaña "Arguments"
4. En "Environment Variables" agrega:
   - Name: `ELEVENLABS_API_KEY`, Value: `tu-api-key-aquí`
   - Name: `ELEVENLABS_AGENT_ID`, Value: `tu-agent-id-aquí`

**Opción 2: .env file (Para producción)**

Crea un archivo de configuración seguro y nunca lo subas a git.

## Paso 5: Probar el Agente

### Test en ElevenLabs Dashboard

Antes de integrar con la app, prueba el agente en el dashboard:

1. Click en "Test Agent" o "Try it"
2. Prueba conversaciones como:
   - "¿Cómo está mi energía?"
   - "¿Cómo dormí anoche?"
   - "¿Debería hacer ejercicio?"
   - "Dame un pronóstico para las próximas 6 horas"

### Test en la App

1. Abre el proyecto en Xcode
2. Asegúrate de que las variables de entorno estén configuradas
3. Ejecuta la app en simulador o dispositivo real
4. Ve a la vista de Energy Coach
5. Toca el botón de voz para iniciar conversación
6. Habla con el agente y verifica que:
   - Se conecta correctamente
   - Responde a tus preguntas
   - Llama las herramientas cuando es apropiado
   - Muestra los datos de HealthKit correctamente

## Paso 6: Optimización y Ajustes

### Ajustar la Voz

Si la voz no suena natural:
1. Prueba diferentes voces en español
2. Ajusta la velocidad (speed) si habla muy rápido/lento
3. Ajusta la estabilidad (stability) para más/menos variación

### Ajustar el System Prompt

Si las respuestas no son como esperas:
1. Sé más específico en el system prompt
2. Agrega más ejemplos de conversaciones
3. Ajusta el tono (más formal/informal)

### Monitorear Uso

1. Ve a Analytics en el dashboard
2. Revisa:
   - Duración promedio de conversaciones
   - Herramientas más usadas
   - Errores o problemas

## Troubleshooting

### Error: "Missing API Key"
- Verifica que `ELEVENLABS_API_KEY` esté configurada
- Verifica que no tenga espacios extra
- Regenera la API key si es necesario

### Error: "Missing Agent ID"
- Verifica que `ELEVENLABS_AGENT_ID` esté configurada
- Verifica que sea el ID correcto del dashboard

### Error: "Connection Failed"
- Verifica tu conexión a internet
- Verifica que la API key sea válida
- Verifica que el agente esté activo en el dashboard

### Las herramientas no se ejecutan
- Verifica que estén configuradas como "client_tool" no "server_tool"
- Verifica que los nombres coincidan exactamente
- Revisa los logs en Xcode para ver errores

### El agente no responde en español
- Verifica que el language esté configurado como "es" o "Spanish"
- Ajusta el system prompt para enfatizar español
- Prueba con una voz diferente

## Recursos

- [ElevenLabs Documentation](https://elevenlabs.io/docs)
- [ElevenLabs Swift SDK](https://github.com/elevenlabs/elevenlabs-swift-sdk)
- [Agent Dashboard](https://elevenlabs.io/app/conversational-ai)
- [API Reference](https://elevenlabs.io/docs/api-reference)

## Costos

ElevenLabs tiene diferentes planes:
- **Free**: Limitado, bueno para testing
- **Starter**: ~$5-11/mes, suficiente para desarrollo
- **Creator**: ~$22-99/mes, para producción
- **Pro**: ~$99+/mes, para escala

Revisa los precios actuales en: https://elevenlabs.io/pricing

