# Environment Variables Setup

## Configuración con archivo .env

Este proyecto usa un archivo `.env` para gestionar las API keys de forma segura.

## Paso 1: Crear archivo .env

1. Copia el archivo de ejemplo:
```bash
cp .env.example .env
```

2. Edita `.env` con tus valores reales:
```bash
ELEVENLABS_API_KEY=sk_1234567890abcdef...
ELEVENLABS_AGENT_ID=agent_abcdef123456...
```

## Paso 2: Agregar .env al proyecto Xcode

**IMPORTANTE**: El archivo `.env` debe estar en el bundle de la app para que se pueda leer.

### Opción A: Agregar manualmente en Xcode

1. En Xcode, arrastra el archivo `.env` al navegador de proyecto
2. Cuando aparezca el diálogo:
   - ✅ Marca "Copy items if needed"
   - ✅ Marca "Add to targets: WelnessHack"
   - Click "Finish"

### Opción B: Usar script de build

Agrega un "Run Script" en Build Phases:

1. En Xcode, ve a Target → Build Phases
2. Click "+" → "New Run Script Phase"
3. Agrega este script:

```bash
# Copy .env file to bundle if it exists
if [ -f "${PROJECT_DIR}/.env" ]; then
    cp "${PROJECT_DIR}/.env" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/.env"
    echo "✅ .env file copied to bundle"
else
    echo "⚠️ .env file not found at ${PROJECT_DIR}/.env"
fi
```

4. Arrastra este script ANTES de "Copy Bundle Resources"

## Paso 3: Verificar configuración

1. Ejecuta la app
2. Revisa la consola de Xcode
3. Deberías ver:
```
✅ Loaded env variable: ELEVENLABS_API_KEY
✅ Loaded env variable: ELEVENLABS_AGENT_ID
```

Si ves errores:
```
⚠️ .env file not found in bundle
```

Significa que el archivo `.env` no está en el bundle. Verifica el Paso 2.

## Seguridad

### ✅ Buenas Prácticas

- `.env` está en `.gitignore` (nunca se sube a git)
- `.env.example` muestra la estructura sin valores reales
- Las keys se cargan solo en runtime
- No hay keys hardcodeadas en el código

### ❌ Nunca hagas esto

- ❌ Subir `.env` a git
- ❌ Compartir tu `.env` con otros
- ❌ Hardcodear API keys en el código
- ❌ Commitear archivos con keys

## Desarrollo en Equipo

Cada desarrollador debe:

1. Copiar `.env.example` a `.env`
2. Obtener sus propias API keys de ElevenLabs
3. Configurar su `.env` local
4. Nunca compartir su `.env`

## Producción

Para producción, considera:

1. **Keychain**: Guardar keys en Keychain de iOS
2. **Backend**: Obtener keys desde tu backend
3. **CI/CD**: Usar secrets de GitHub Actions / Xcode Cloud

Ejemplo con Keychain:

```swift
// Guardar
KeychainHelper.save(key: "ELEVENLABS_API_KEY", value: apiKey)

// Leer
let apiKey = KeychainHelper.load(key: "ELEVENLABS_API_KEY")
```

## Troubleshooting

### Error: ".env file not found in bundle"

**Solución 1**: Verifica que `.env` esté agregado al target
1. Selecciona `.env` en el navegador
2. En el inspector de archivos (derecha), verifica "Target Membership"
3. Marca "WelnessHack"

**Solución 2**: Usa el script de build (ver Opción B arriba)

**Solución 3**: Agrega manualmente a "Copy Bundle Resources"
1. Target → Build Phases → Copy Bundle Resources
2. Click "+" y agrega `.env`

### Error: "Missing required environment variable"

**Causa**: El archivo `.env` existe pero está vacío o mal formateado

**Solución**:
1. Abre `.env`
2. Verifica formato: `KEY=VALUE` (sin espacios alrededor de `=`)
3. No uses comillas: `ELEVENLABS_API_KEY=sk_123` (no `"sk_123"`)
4. Una variable por línea

### Las variables no se cargan

**Solución**: Verifica que `EnvLoader.loadEnv()` se llame en `WelnessHackApp.init()`

```swift
@main
struct WelnessHackApp: App {
    init() {
        EnvLoader.loadEnv()  // ← Debe estar aquí
    }
    // ...
}
```

## Alternativa: Variables de Entorno de Xcode

Si prefieres no usar archivo `.env`, puedes usar variables de entorno de Xcode:

1. Product → Scheme → Edit Scheme
2. Run → Arguments → Environment Variables
3. Agrega:
   - `ELEVENLABS_API_KEY` = tu-key
   - `ELEVENLABS_AGENT_ID` = tu-agent-id

**Ventaja**: No necesitas archivo `.env`  
**Desventaja**: Cada desarrollador debe configurar manualmente

## Ejemplo Completo

### .env
```bash
# ElevenLabs Configuration
ELEVENLABS_API_KEY=sk_1234567890abcdef1234567890abcdef
ELEVENLABS_AGENT_ID=agent_abcdef1234567890
```

### Uso en código
```swift
// Cargar al inicio
EnvLoader.loadEnv()

// Usar en cualquier lugar
let apiKey = EnvLoader.get("ELEVENLABS_API_KEY")
let agentID = EnvLoader.get("ELEVENLABS_AGENT_ID")

// O directamente desde ElevenLabsConfig
let apiKey = ElevenLabsConfig.apiKey
let agentID = ElevenLabsConfig.agentID
```

## Recursos

- [ElevenLabs API Keys](https://elevenlabs.io/app/settings/api-keys)
- [ElevenLabs Agents](https://elevenlabs.io/app/conversational-ai)
- [Xcode Environment Variables](https://developer.apple.com/documentation/xcode/customizing-the-build-schemes-for-a-project)

