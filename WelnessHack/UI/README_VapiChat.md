# VapiChatScreen - Documentación

## 📱 Vista General

La pantalla `VapiChatScreen` es una interfaz de chat por voz con un chatbot, diseñada según el wireframe proporcionado.

## ✅ Componentes Implementados (Frontend)

### 1. **AvatarView** (`UI/Components/AvatarView.swift`)
- ✅ Avatar circular del chatbot
- ✅ Efecto de glow cuando está activo/hablando
- ✅ Soporte para imagen personalizada (URL)
- ✅ Placeholder con ícono de persona
- ✅ Animaciones fluidas

### 2. **AudioWaveformView** (`UI/Components/AudioWaveformView.swift`)
- ✅ Barras de audio animadas (5 barras)
- ✅ Animación cuando el bot está hablando
- ✅ Estado idle (barras pequeñas)
- ✅ Duraciones aleatorias para efecto natural
- ✅ Gradiente coral/naranja

### 3. **VapiChatScreen** (`UI/Screens/VapiChatScreen.swift`)
- ✅ Background 3D animado con Spline
- ✅ Fallback gradient si Spline no carga
- ✅ Layout vertical según wireframe:
  - Avatar arriba
  - Waveform en medio
  - Status de conexión
  - Botón de micrófono abajo
- ✅ Integración con ViewModel
- ✅ Manejo de estados visuales
- ✅ Previews para diferentes estados

### 4. **VapiChatViewModel** (`UI/Screens/VapiChatViewModel.swift`)
- ✅ Estados de UI (@Published properties)
- ✅ Métodos mock para testing UI
- ✅ Simuladores de bot/usuario hablando
- ⚠️ Backend pendiente (ver sección abajo)

### 5. **VoiceButtonView** (Reutilizado)
- ✅ Ya existente en `Features/DailyFlow/`
- ✅ Reutilizado para el botón de micrófono
- ✅ Animaciones y estados visuales

## 🎨 Características de UI

### Estados Visuales Implementados
1. **Desconectado** (Idle)
   - Avatar gris sin glow
   - Waveform estático (barras pequeñas)
   - Botón "Iniciar" azul/púrpura

2. **Conectado - Escuchando**
   - Avatar con glow azul
   - Waveform estático
   - Botón "Escuchando" cyan
   - Indicador verde de conexión

3. **Bot Hablando**
   - Avatar con glow pulsante
   - Waveform animado (barras moviéndose)
   - Botón con gradiente verde/azul
   - Texto "Bot hablando"

4. **Usuario Hablando**
   - Avatar activo
   - Waveform puede animarse (opcional)
   - Estado "Escuchando..." en UI

### Animaciones
- ✅ Glow pulsante en avatar
- ✅ Waveform con movimiento fluido
- ✅ Transiciones suaves entre estados
- ✅ Efectos de sombra y profundidad

## ⚠️ Backend Pendiente de Implementar

### Archivos que se necesitan crear:

#### 1. **VapiClient.swift** (NO EXISTE)
```swift
// Ubicación sugerida: Core/VapiIntegration/VapiClient.swift

@MainActor
class VapiClient: ObservableObject {
    // Propiedades
    @Published var isConnected: Bool
    @Published var isSpeaking: Bool
    
    // Métodos necesarios
    func startSession() async throws
    func endSession() async throws
    func sendAudio(_ data: Data) async throws
    
    // Callbacks
    var onSpeechStart: (() -> Void)?
    var onSpeechEnd: (() -> Void)?
    var onTranscript: ((String) -> Void)?
    var onError: ((Error) -> Void)?
}
```

#### 2. **VapiConfig.swift** (NO EXISTE)
```swift
// Ubicación sugerida: Core/VapiIntegration/VapiConfig.swift

struct VapiConfig {
    static let publicKey = EnvLoader.value(for: "VAPI_PUBLIC_KEY")
    static let assistantId = EnvLoader.value(for: "VAPI_ASSISTANT_ID")
    
    static func validate() throws {
        guard !publicKey.isEmpty else {
            throw VapiError.missingPublicKey
        }
        guard !assistantId.isEmpty else {
            throw VapiError.missingAssistantId
        }
    }
}
```

#### 3. **AudioManager.swift** (NO EXISTE)
```swift
// Ubicación sugerida: Core/Audio/AudioManager.swift

import AVFoundation

class AudioManager: ObservableObject {
    private var audioEngine: AVAudioEngine?
    private var inputNode: AVAudioInputNode?
    
    // Solicitar permisos
    func requestMicrophonePermission() async throws -> Bool
    
    // Captura de audio
    func startRecording() throws
    func stopRecording()
    
    // Obtener nivel de audio para waveform
    func getAudioLevel() -> Float
    
    // Callbacks
    var onAudioData: ((Data) -> Void)?
}
```

### Integraciones necesarias:

#### 1. **Vapi SDK o API REST**
Opciones:
- **Opción A:** Usar Vapi iOS SDK (si existe)
  ```swift
  dependencies: [
      .package(url: "https://github.com/VapiAI/ios-sdk", from: "1.0.0")
  ]
  ```

- **Opción B:** Implementar cliente REST/WebSocket personalizado
  ```swift
  // WebSocket para streaming de audio
  import Starscream // Ya instalado
  
  class VapiWebSocketClient {
      private var socket: WebSocket?
      
      func connect(publicKey: String, assistantId: String) async throws
      func sendAudioChunk(_ data: Data) async throws
      func disconnect()
  }
  ```

#### 2. **Permisos en Info.plist**
```xml
<key>NSMicrophoneUsageDescription</key>
<string>Necesitamos acceso al micrófono para hablar con el chatbot por voz.</string>
```

#### 3. **Variables de entorno (.env)**
```bash
VAPI_PUBLIC_KEY=your_public_key_here
VAPI_ASSISTANT_ID=your_assistant_id_here
```

### Métodos del ViewModel a implementar:

En `VapiChatViewModel.swift`, los siguientes métodos tienen **TODO** comments:

```swift
// Línea ~50
func startChatSession() async {
    // TODO: BACKEND - Implementar conexión con Vapi
    // 1. Solicitar permisos de micrófono
    // 2. Inicializar VapiClient
    // 3. Configurar callbacks
    // 4. Iniciar sesión
}

// Línea ~110
func endChatSession() async {
    // TODO: BACKEND - Implementar desconexión
}

// Línea ~145
private func requestMicrophonePermission() async throws {
    // TODO: BACKEND - Implementar solicitud de permisos
    // import AVFoundation
    // AVAudioSession.sharedInstance().requestRecordPermission()
}
```

## 🧪 Testing de UI

### Controles de Debug (Solo en DEBUG builds)
La pantalla incluye botones de testing que permiten simular estados sin backend:

- **"Bot Habla"**: Simula que el bot está hablando (3 segundos)
- **"Usuario Habla"**: Simula que el usuario está hablando (2 segundos)

Estos botones solo aparecen cuando:
1. Estás en modo DEBUG (#if DEBUG)
2. La sesión está conectada

### Previews de Xcode
Se incluyen 3 previews:
1. **Default**: Estado inicial (desconectado)
2. **Connected - Bot Speaking**: Bot hablando con waveform animado
3. **Connected - Listening**: Conectado esperando input del usuario

## 📐 Estructura del Layout

```
VapiChatScreen
├── ZStack
│   ├── SplineView (Background 3D)
│   │   └── Fallback: LinearGradient
│   └── VStack (Content)
│       ├── Spacer (80pt top)
│       ├── AvatarView (140x140)
│       ├── Spacer (60pt)
│       ├── AudioWaveformView (80pt height)
│       ├── Spacer (flexible)
│       ├── Connection Status (Text + indicator)
│       ├── VoiceButtonView (120x120)
│       ├── [DEBUG] Test Controls
│       └── Spacer (60pt bottom)
```

## 🎯 Próximos Pasos

### Para completar la funcionalidad:

1. **Decisión de plataforma**
   - ¿Usar Vapi o ElevenLabs?
   - Si Vapi: instalar SDK
   - Si ElevenLabs: adaptar código existente

2. **Implementar VapiClient**
   - Conexión WebSocket
   - Streaming de audio
   - Callbacks de eventos

3. **Implementar AudioManager**
   - Captura de micrófono
   - Procesamiento de audio
   - Detección de amplitud

4. **Configurar permisos**
   - Agregar a Info.plist
   - Implementar flujo de autorización

5. **Agregar variables de entorno**
   - Crear/actualizar .env
   - Agregar VAPI_PUBLIC_KEY
   - Agregar VAPI_ASSISTANT_ID

6. **Testing**
   - Probar en dispositivo real (micrófono)
   - Verificar latencia de audio
   - Optimizar animaciones

## 📝 Notas Importantes

- **El frontend está 100% completo y funcional para testing visual**
- **Todos los componentes tienen animaciones y estados correctos**
- **El código está preparado para integrar backend fácilmente**
- **Los TODOs están claramente marcados en el código**
- **La UI es responsive y adaptable a diferentes tamaños de pantalla**

## 🔗 Archivos Relacionados

- `VapiChatScreen.swift` - Pantalla principal
- `VapiChatViewModel.swift` - Lógica de presentación
- `AvatarView.swift` - Componente de avatar
- `AudioWaveformView.swift` - Componente de waveform
- `VoiceButtonView.swift` - Componente de botón (reutilizado)
- `README_VapiChat.md` - Esta documentación
