# Calendar Backend - Fase 1: Persistencia Local

## ✅ Implementación Completada

Se ha implementado el sistema de persistencia local para eventos de calendario usando **SwiftData**.

### Archivos Creados

```
Features/Calendar/
├── Models/
│   ├── CalendarEvent.swift           [NUEVO] - Modelo de UI
│   └── StoredCalendarEvent.swift     [NUEVO] - Modelo SwiftData
│
Services/Calendar/
├── CalendarStore.swift                [NUEVO] - Gestor de persistencia
└── README_CalendarBackend.md          [ESTE ARCHIVO]

Features/Calendar/
└── Views/
    └── CreateEventSheet.swift         [NUEVO] - UI para CRUD

[MODIFICADOS]
- WelnessHackApp.swift                 → SwiftData configurado
- CalendarViewModel.swift              → Integrado con CalendarStore
- CalendarScreen.swift                 → Pasa modelContainer al ViewModel
```

---

## 📖 Guía de Uso

### 1. Crear un Evento

```swift
// Desde el ViewModel
await viewModel.addEvent(
    title: "Team Meeting",
    date: Date(),
    duration: 3600  // 1 hora en segundos
)

// Desde la UI usando CreateEventSheet
@State private var showCreateEvent = false

Button("Crear Evento") {
    showCreateEvent = true
}
.sheet(isPresented: $showCreateEvent) {
    CreateEventSheet(viewModel: viewModel)
}
```

### 2. Editar un Evento

```swift
// Desde el ViewModel
let updatedEvent = CalendarEvent(
    id: existingEvent.id,  // Mantener el mismo ID
    title: "Updated Title",
    startDate: newDate,
    endDate: newEndDate,
    // ... otros campos
)

await viewModel.updateEvent(updatedEvent)

// Desde la UI usando EditEventSheet
@State private var showEditEvent = false
@State private var selectedEvent: CalendarEvent?

Button("Editar") {
    selectedEvent = event
    showEditEvent = true
}
.sheet(item: $selectedEvent) { event in
    EditEventSheet(viewModel: viewModel, event: event)
}
```

### 3. Eliminar un Evento

```swift
// Desde el ViewModel
await viewModel.deleteEvent(event)

// Desde la UI con confirmación
Button(role: .destructive) {
    Task {
        await viewModel.deleteEvent(event)
    }
} label: {
    Label("Eliminar", systemImage: "trash")
}
.confirmationDialog("¿Eliminar evento?", isPresented: $showConfirm) {
    Button("Eliminar", role: .destructive) {
        Task { await viewModel.deleteEvent(event) }
    }
}
```

### 4. Consultar Eventos

```swift
// Eventos del día seleccionado
let todayEvents = viewModel.todayEvents

// Eventos del mes actual
let monthEvents = viewModel.monthEvents

// Eventos de una hora específica
let events = viewModel.getEvents(for: date, hour: 14)

// Directamente desde CalendarStore
if let store = calendarStore {
    // Todos los eventos
    let allEvents = try store.fetchAllEvents()
    
    // Eventos de un día
    let dayEvents = try store.fetchEvents(for: Date())
    
    // Eventos de un rango
    let rangeEvents = try store.fetchEvents(from: startDate, to: endDate)
    
    // Eventos por fuente
    let userEvents = try store.fetchEvents(source: .user)
}
```

---

## 🗃️ Modelos de Datos

### CalendarEvent (Modelo de UI)

```swift
struct CalendarEvent: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var startDate: Date
    var endDate: Date
    var isAllDay: Bool
    var location: String?
    var notes: String?
    var source: EventSource
}
```

### EventSource (Fuentes de Eventos)

```swift
enum EventSource: String, Codable {
    case system     // Calendario del sistema
    case user       // Creado por el usuario
    case healthKit  // Generado desde HealthKit
    case ai         // Sugerido por IA
}
```

### StoredCalendarEvent (Modelo SwiftData)

```swift
@Model
final class StoredCalendarEvent {
    @Attribute(.unique) var id: UUID
    var title: String
    var startDate: Date
    var endDate: Date
    var isAllDay: Bool
    var location: String?
    var notes: String?
    var sourceRawValue: String
    var createdAt: Date
    var updatedAt: Date
}
```

---

## 🔄 Flujo de Datos

```
┌─────────────────────┐
│   UI (SwiftUI)      │
│  CreateEventSheet   │
└──────────┬──────────┘
           │
     ┌─────▼─────────────┐
     │ CalendarViewModel │
     └─────────┬─────────┘
               │
      ┌────────▼──────────┐
      │  CalendarStore    │
      │   (SwiftData)     │
      └────────┬──────────┘
               │
      ┌────────▼──────────────┐
      │ StoredCalendarEvent   │
      │    (Persistencia)     │
      └───────────────────────┘
```

---

## 💾 Persistencia

Los eventos se guardan automáticamente en:
- **iOS Simulator**: `~/Library/Developer/CoreSimulator/...`
- **Dispositivo físico**: Sandbox de la app

**Características:**
- ✅ Persiste entre reinicios de la app
- ✅ Sincronización automática con SwiftData
- ✅ CRUD completo (Create, Read, Update, Delete)
- ✅ Queries optimizadas por fecha y fuente
- ✅ Timestamps automáticos (createdAt, updatedAt)

---

## 🧪 Testing

### Crear eventos de prueba

```swift
// En el ViewModel init, puedes activar:
loadMockEvents()  // Carga eventos de ejemplo

// O desde CalendarStore:
let testEvents = [
    CalendarEvent(
        title: "Test Event 1",
        startDate: Date(),
        endDate: Date().addingTimeInterval(3600),
        source: .user
    ),
    CalendarEvent(
        title: "Test Event 2",
        startDate: Date().addingTimeInterval(7200),
        endDate: Date().addingTimeInterval(10800),
        source: .ai
    )
]

try await store.createEvents(testEvents)
```

### Limpiar base de datos

```swift
try store.deleteAllEvents()
```

### Ver estadísticas

```swift
let total = try store.countAllEvents()
let userEvents = try store.countEvents(source: .user)
print("Total: \(total), Usuario: \(userEvents)")
```

---

## 🚀 Próximos Pasos (Fase 2)

### EventKit Integration
- [ ] Crear `EventKitManager.swift`
- [ ] Solicitar permisos de calendario
- [ ] Leer eventos del calendario nativo
- [ ] Crear eventos en calendario nativo
- [ ] Sincronización bidireccional

### CalendarManager (Gestor Central)
- [ ] Crear `CalendarManager.swift`
- [ ] Combinar eventos de múltiples fuentes:
  - CalendarStore (eventos locales)
  - EventKit (eventos del sistema)
  - HealthKit (eventos de salud)
- [ ] Lógica de sincronización unificada

### Integración con Chatbot
- [ ] Crear `CalendarAIService.swift`
- [ ] Actualizar `VapiChatViewModel`
- [ ] Comandos de voz para CRUD
- [ ] Sugerencias basadas en Body Battery

---

## 📝 Notas Importantes

1. **Migración de Datos**: Si cambias el schema de SwiftData, necesitarás una migración
2. **Performance**: Las queries están optimizadas, pero con >1000 eventos considera paginación
3. **Backup**: SwiftData puede sincronizar con iCloud si se configura
4. **Testing**: Los eventos se guardan en memoria si `isStoredInMemoryOnly: true`

---

## 🐛 Troubleshooting

### Error: "Could not initialize ModelContainer"
- Verifica que `StoredCalendarEvent` tenga el decorator `@Model`
- Asegúrate de importar SwiftData

### Los eventos no persisten
- Verifica que `isStoredInMemoryOnly: false` en ModelConfiguration
- Confirma que `try modelContext.save()` se llama después de cambios

### Eventos duplicados
- Verifica que el `id` sea único
- El atributo `@Attribute(.unique)` previene duplicados

---

## 📚 Recursos

- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [EventKit Documentation](https://developer.apple.com/documentation/eventkit)
- [HealthKit Workouts](https://developer.apple.com/documentation/healthkit/workouts_and_activity_rings)
