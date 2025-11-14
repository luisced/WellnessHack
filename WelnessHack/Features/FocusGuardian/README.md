# Focus Guardian Feature

## 📋 Overview

Focus mode feature que ayuda a los usuarios a mantener enfoque y tomar descansos. Incluye timer tipo Pomodoro con visualización elegante y mensajes motivacionales.

## 🎯 User Value

- Timer de enfoque con visualización clara
- Mensajes motivacionales contextuales
- Fondo animado 3D (Spline)
- Transiciones suaves entre estados
- Control de pausar/reanudar/detener

## 📱 Screens & Components

### Main Screen
- `FocusScreen.swift` - Pantalla principal con fondo Spline y timer

### Views
- `ClockView.swift` - Reloj inicial (estado idle)
- `TimerCircleView.swift` - Timer circular con progreso
- `MotivationalMessagesView.swift` - Burbujas con mensajes motivacionales

### ViewModels
- `FocusViewModel.swift` - Lógica del timer, estados y mensajes

## 🔄 User Flow

### Estado Idle
1. Usuario ve "TAKE A BREAK" título
2. Reloj analógico en centro
3. Mensaje motivacional abajo
4. Click en reloj inicia timer

### Estado Active
1. Título reduce tamaño
2. Reloj desaparece con fade
3. Timer circular aparece con fade (mismo centro)
4. Muestra tiempo restante y progreso
5. Controles aparecen abajo (pausa, stop)
6. Mensajes cambian contextualmente

### Pausa
1. Timer se detiene
2. Botón cambia a "play"
3. Mensaje indica estado pausado

## 🎨 Design System

### Colors Used
- `focusBlue` - Azul principal (#2D5D7B)
- `focusBackground` - Fondo azul oscuro (#1A365D)

### Typography
- Título: `.displayLarge` (36pt) → `.displayMedium` (28pt cuando activo)
- Timer: `.monospaceLarge` (36pt monospaced)
- Mensajes: `.bodyMedium` (16pt)

### Animations
- Fade in/out (0.8s ease in out)
- Timer aparece en misma posición que reloj
- Sin movimiento vertical (solo opacity)

## 🔗 Dependencies

### Core
- Ninguna actualmente

### Services
- **ScreenTime** (futuro) - Para focus mode real y app blocking

### Resources
- `meditation_copy.splineswift` - Fondo animado 3D

## 📊 Data Models

```swift
enum FocusState {
    case idle
    case active
    case paused
}

enum SessionType {
    case focus
    case break
    case longBreak
}
```

## 🚧 TODOs & Future Work

### Backend Integration
- [ ] Persistir sesiones completadas
- [ ] Estadísticas de enfoque
- [ ] Integración con ScreenTime API

### Features
- [ ] Configuración de duración de sesiones
- [ ] Notificaciones de fin de sesión
- [ ] Sonidos de inicio/fin
- [ ] Modo no molestar automático
- [ ] Bloqueo de apps durante focus

### UI Improvements
- [ ] Selector de tipo de sesión (Pomodoro, custom)
- [ ] Historia de sesiones completadas
- [ ] Gráficas de productividad
- [ ] Temas personalizables

## 🧪 Testing

### Unit Tests Needed
- [ ] `FocusViewModel` - Estado transitions
- [ ] `FocusViewModel` - Timer countdown logic
- [ ] Message rotation logic

### UI Tests Needed
- [ ] Click en reloj inicia timer
- [ ] Pausar/reanudar funciona
- [ ] Stop resetea timer
- [ ] Mensajes rotan correctamente

## 📝 Notes

- Timer centrado en misma posición que reloj (sin movimiento)
- Usa solo fade transitions (sin scale ni move)
- Color del timer cambiado de naranja a azul fuerte
- Reloj pequeño removido del título
- Fondo Spline cubre pantalla completa
- Mensajes son mock data
