# WelnessHack - AI Energy Coach

Un coach de energía personal impulsado por IA que utiliza datos de HealthKit y ElevenLabs para ayudarte a optimizar tu energía diaria.

## 🎯 Características

- **Body Battery**: Calcula tu nivel de energía (0-100) basado en:
  - Calidad y duración del sueño
  - HRV (Variabilidad Cardíaca)
  - Nivel de actividad física

- **Coach de Voz con IA**: Conversaciones naturales en español usando ElevenLabs
  - Análisis de tu energía actual
  - Pronósticos de energía para próximas horas
  - Recomendaciones personalizadas
  - Análisis detallado de sueño y actividad

- **Dashboard Visual**: Visualización clara de tus métricas de salud

## 📋 Requisitos

- iOS 14.0+
- Xcode 15.0+
- Swift 5.9+
- Cuenta de ElevenLabs
- Apple Watch (opcional, para mejores datos de HRV)

## 🚀 Instalación

### 1. Clonar el repositorio

```bash
git clone https://github.com/tu-usuario/WelnessHack.git
cd WelnessHack
```

### 2. Instalar dependencias

El proyecto usa Swift Package Manager. Las dependencias se instalarán automáticamente al abrir el proyecto en Xcode.

Dependencias:
- [ElevenLabs Swift SDK](https://github.com/elevenlabs/elevenlabs-swift-sdk) (v2.0.0+)

### 3. Configurar ElevenLabs

Sigue la guía completa en [docs/ELEVENLABS_SETUP.md](./docs/ELEVENLABS_SETUP.md)

Pasos rápidos:
1. Crea cuenta en [ElevenLabs](https://elevenlabs.io)
2. Crea un agente con el system prompt y tools proporcionados
3. Configura las variables de entorno en Xcode:
   - `ELEVENLABS_API_KEY`
   - `ELEVENLABS_AGENT_ID`

### 4. Configurar HealthKit

El proyecto ya incluye los permisos necesarios en `Info.plist`. Solo necesitas:
1. Habilitar HealthKit capability en Xcode
2. Autorizar los permisos cuando la app lo solicite

## 📱 Uso

1. **Primera vez**: La app solicitará permisos de HealthKit
2. **Dashboard**: Verás tu nivel de energía actual y métricas
3. **Iniciar conversación**: Toca el botón de voz para hablar con tu coach
4. **Preguntas que puedes hacer**:
   - "¿Cómo está mi energía?"
   - "¿Cómo dormí anoche?"
   - "¿Debería hacer ejercicio?"
   - "Dame un pronóstico para las próximas 6 horas"
   - "Tengo una reunión importante, ¿qué me recomiendas?"

## ��️ Arquitectura

El proyecto sigue una arquitectura de feature slicing:

```
WelnessHack/
├── Features/           # Feature slices (DailyFlow, etc.)
├── Core/              # Engines compartidos
│   ├── BodyBattery/   # Cálculo de energía
│   └── ElevenLabsIntegration/  # Cliente de ElevenLabs
├── Services/          # Integraciones de plataforma
│   └── HealthKit/     # Manager de HealthKit
├── Data/              # Modelos y persistencia
└── UI/                # Componentes SwiftUI

```

Ver documentación completa en [docs/PROJECT_STRUCTURE.md](./docs/PROJECT_STRUCTURE.md)

## 🧪 Testing

```bash
# Ejecutar tests unitarios
cmd + U en Xcode

# O desde terminal
xcodebuild test -scheme WelnessHack
```

## 📚 Documentación

- [Estructura del Proyecto](./docs/PROJECT_STRUCTURE.md)
- [Setup de ElevenLabs](./docs/ELEVENLABS_SETUP.md)
- [Feature Slicing](./docs/FEATURE_SLICING.md)
- [Modelos de Datos](./docs/DATA_MODELS.md)

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## �� Licencia

Este proyecto está bajo la licencia MIT. Ver `LICENSE` para más detalles.

## 🙏 Agradecimientos

- [ElevenLabs](https://elevenlabs.io) por su increíble SDK de voz
- Apple HealthKit por los datos de salud
- La comunidad de Swift por las herramientas

## 📞 Soporte

Si tienes problemas:
1. Revisa la [documentación](./docs/)
2. Revisa los [issues existentes](https://github.com/tu-usuario/WelnessHack/issues)
3. Crea un nuevo issue si es necesario

---

Hecho con ❤️ para ayudarte a optimizar tu energía diaria
