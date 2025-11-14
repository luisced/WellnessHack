# 🧭 Sistema de Navegación Principal

## 📱 Arquitectura

### **MainTabView.swift**
Contenedor principal de la aplicación con navegación personalizada entre 4 pantallas principales.

#### **4 Screens Principales:**
1. **VapiChatScreen** - Chat con asistente de voz
2. **FocusScreen** - Timer de enfoque y meditación  
3. **CalendarScreen** - Vista de calendario con eventos
4. **DashboardScreen** - Dashboard de métricas de salud

---

## 🎨 Sistema de Transiciones

### **1. VapiChat ↔ Otras Screens**
**Tipo:** Slide + Blur con Partículas
- **Efecto:** Deslizamiento suave con partículas flotantes
- **Duración:** 0.5 segundos
- **Por qué:** Refleja la naturaleza conversacional y etérea de la voz

```swift
TransitionModifiers.slideBlurWithParticles()
```

### **2. FocusScreen ↔ Otras Screens**
**Tipo:** Zoom desde Centro
- **Efecto:** Scale del 80% al 100% con fade
- **Duración:** 0.5 segundos
- **Por qué:** Emerge desde el reloj central, enfatiza el tiempo

```swift
TransitionModifiers.zoomFromCenter()
```

### **3. Calendar ↔ Dashboard**
**Tipo:** Gradiente Animado Suave
- **Efecto:** Transición de color fluida del gradiente de fondo
- **Duración:** 1.0 segundo
- **Por qué:** Conexión visual entre datos personales y tiempo

```swift
TransitionModifiers.smoothGradient()
```

### **4. Dashboard → VapiChat (cierre de ciclo)**
**Tipo:** Slide Simple con Fade
- **Duración:** 0.5 segundos
- **Por qué:** Transición limpia para cerrar el flujo circular

```swift
TransitionModifiers.simpleFadeSlide()
```

---

## 🎨 Sistema de Gradientes Animados

### **VapiChat**
```swift
Color.vapiGradientStart (Azul Cielo #87CEEB)
→ Color.vapiGradientEnd (Blanco)
```

### **FocusScreen**
```swift
Color.focusBackground (Propio de FocusScreen)
→ Color.focusBlue.opacity(0.3)
// Usa su propio fondo Spline 3D
```

### **Calendar**
```swift
Color.gradientMint (#A2D9CE)
→ Color.gradientWhite (#EBEFF5)
→ Color.calendarWhite
```

### **Dashboard**
```swift
Color.gradientDarkBlue (#365069, 80%)
→ Color.gradientMediumBlue (#6C949C, 70%)
→ Color.gradientMint (#A2D9CE, 35%)
→ Color.gradientWhite (#EBEFF5, 3%)
```

---

## ✨ 4 Mejoras UX Implementadas

### **1. Tab Bar con Indicador Animado**
- Línea animada debajo del tab seleccionado
- Animación spring con `matchedGeometryEffect`
- Color del indicador cambia según el tab

```swift
Capsule()
    .fill(tab.color)
    .frame(width: 30, height: 3)
    .matchedGeometryEffect(id: "indicator", in: namespace)
```

### **2. Haptic Feedback**
- Vibración ligera al cambiar de tab
- `UIImpactFeedbackGenerator(style: .light)`
- Refuerza la sensación táctil

```swift
HapticManager.shared.selection()
```

### **3. Íconos Animados**
- Scale effect en el ícono seleccionado (1.0 → 1.2)
- Spring animation suave
- Cambio de color coordinado

```swift
.scaleEffect(isSelected ? 1.2 : 1.0)
.animation(.spring(response: 0.3, dampingFraction: 0.6))
```

### **4. Transición de Gradiente**
- Duración: 1.0 segundo
- Easing: `.easeInOut`
- Sincronizado con cambio de tab

```swift
.animation(.easeInOut(duration: 1.0), value: selectedTab)
```

---

## 📂 Archivos Creados

### **Core Navigation**
- `MainTabView.swift` - Vista principal con navegación
- `CustomTabBar.swift` - Tab bar personalizado con animaciones

### **Utilities**
- `TransitionModifiers.swift` - Modificadores de transición reutilizables
- `HapticManager.swift` - Manager centralizado de feedback háptico

### **Components**
- `ParticleEffect` - Efecto de partículas para VapiChat
- `AnimatedGradientBackground` - Fondo con gradiente animado

---

## 🎯 Uso

### **En WelnessHackApp.swift:**
```swift
var body: some Scene {
    WindowGroup {
        ContentView() // Usa MainTabView internamente
    }
}
```

### **En ContentView.swift:**
```swift
var body: some View {
    MainTabView()
}
```

---

## 🔧 Personalización

### **Cambiar Transiciones:**
Edita `TransitionModifiers.swift` para crear nuevas transiciones.

### **Cambiar Gradientes:**
Edita `AnimatedGradientBackground` en `MainTabView.swift`.

### **Cambiar Íconos del Tab:**
Edita `CustomTabBar.defaultTabs` en `CustomTabBar.swift`.

### **Ajustar Haptics:**
Edita métodos en `HapticManager.swift`.

---

## 🎨 Paleta de Colores

Todos los colores están definidos en `UI/Theme/Colors.swift`:

```swift
// Gradient colors
.gradientDarkBlue   // #365069 al 80%
.gradientMediumBlue // #6C949C al 70%
.gradientMint       // #A2D9CE al 35%
.gradientWhite      // #EBEFF5 al 3%

// VapiChat colors
.vapiGradientStart  // #87CEEB (Azul Cielo)
.vapiGradientEnd    // Blanco

// Calendar colors (ya existentes)
.calendarMint
.calendarWhite
.calendarDarkBlue
.calendarLightBlue

// Focus colors (ya existentes)
.focusBackground
.focusBlue
```

---

## 🚀 Siguiente Paso

La navegación está completamente funcional. Para probar:

1. **Build** el proyecto (⌘+B)
2. **Run** en simulador o dispositivo (⌘+R)
3. **Navega** entre los tabs para ver las transiciones
4. **Siente** el haptic feedback al cambiar

---

## 📝 Notas Técnicas

- **Performance:** Todas las animaciones usan `.animation()` modifier, optimizado por SwiftUI
- **Memory:** Las transiciones se limpian automáticamente después de completarse
- **Compatibility:** Requiere iOS 17.0+
- **Dependencies:** SplineRuntime (para FocusScreen background)
