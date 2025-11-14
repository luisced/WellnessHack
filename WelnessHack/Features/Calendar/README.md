# Calendar Feature

## 📋 Overview

Calendar integration feature que muestra eventos del usuario con una vista moderna y scrolleable. Permite visualizar días, horas, y eventos con un diseño limpio inspirado en calendarios modernos.

## 🎯 User Value

- Visualización clara de eventos del calendario
- Navegación fluida por días y horas
- Scroll bidireccional (horizontal para días, vertical para horas)
- Selector de mes/año intuitivo
- Botón flotante para crear eventos rápidos

## 📱 Screens & Components

### Main Screen
- `CalendarScreen.swift` - Pantalla principal del calendario con gradiente de fondo

### Views
- `ModernCalendarView.swift` - Vista principal del calendario con scroll bidireccional
- `CalendarHeader.swift` - Header con días de la semana y efecto glassmorphism
- `CalendarWeekView.swift` - Vista de semana (legacy, puede ser removida)
- `CalendarHourLabels.swift` - Etiquetas de horas laterales
- `CalendarHourRangeSlider.swift` - Control para ajustar rango de horas visible
- `CalendarEventCard.swift` - Tarjeta individual de evento

### ViewModels
- `CalendarViewModel.swift` - Lógica del calendario, gestión de eventos y navegación

## 🔄 User Flow

1. Usuario abre tab de Calendar
2. Ve calendario con gradiente de fondo
3. Puede scrollear horizontalmente para ver más días (-7 a +7 días)
4. Puede scrollear verticalmente para ver todas las horas del día
5. Click en mes abre selector de mes/año
6. Click en botón "+" permite crear evento (placeholder)
7. Click en slot de tiempo permite crear evento en esa hora

## 🎨 Design System

### Colors Used
- `calendarDarkBlue` - Azul fuerte del gradiente
- `calendarLightBlue` - Azul leve transición
- `calendarMint` - Menta centro
- `calendarWhite` - Blanco superior

### Typography
- Títulos: `.displayLarge` (36pt bold)
- Subtítulos: `.headlineMedium` (18pt semibold)
- Body: `.bodyMedium` (16pt regular)
- Captions: `.captionMedium` (12pt regular)

## 🔗 Dependencies

### Core
- Ninguna dependencia de Core actualmente (eventos son mock)

### Services
- **Calendar service** (futuro) - Integración con Apple Calendar

### Data
- `CalendarEvent` model (definido en ViewModel temporalmente)

## 📊 Data Models

```swift
struct CalendarEvent: Identifiable {
    let id: UUID
    let title: String
    let startDate: Date
    let endDate: Date
    let source: EventSource
}

enum EventSource {
    case apple
    case google
    case manual
}
```

## 🚧 TODOs & Future Work

### Backend Integration
- [ ] Conectar con Apple Calendar API
- [ ] Implementar persistencia de eventos
- [ ] Sincronización con calendarios externos (Google, Outlook)

### Features
- [ ] Crear/editar/eliminar eventos (actualmente solo UI)
- [ ] Agregar notificaciones de eventos
- [ ] Vista mensual/semanal/diaria
- [ ] Filtros por tipo de evento
- [ ] Búsqueda de eventos

### UI Improvements
- [ ] Optimizar performance de scroll
- [ ] Animaciones de transición entre meses
- [ ] Soporte para eventos de día completo
- [ ] Colores personalizables por tipo de evento

## 🧪 Testing

### Unit Tests Needed
- [ ] `CalendarViewModel` - Navegación de fechas
- [ ] `CalendarViewModel` - Organización de eventos por hora
- [ ] Date calculations y formatters

### UI Tests Needed
- [ ] Scroll horizontal/vertical
- [ ] Selección de mes
- [ ] Click en eventos
- [ ] Creación de eventos

## 📝 Notes

- Eventos actualmente son mock data
- Scroll bidireccional implementado con nested `ScrollView`
- Header usa glassmorphism (`.ultraThinMaterial`)
- Botón flotante es placeholder sin lógica real
