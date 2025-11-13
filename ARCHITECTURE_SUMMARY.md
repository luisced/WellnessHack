# WelnessHack Architecture Summary

## Project Status: Directory Structure Complete ✓

This document provides a high-level summary of the WelnessHack project structure and how to navigate the codebase.

---

## Directory Structure

```
WelnessHack/
├── Features/                      # Vertically sliced features
│   ├── Onboarding/               # User setup, permissions, goal selection
│   ├── DailyFlow/                # Morning briefing, chat, evening reflection
│   ├── Nutrition/                # Food capture, analysis, meal logging
│   ├── FocusGuardian/            # Work-life boundaries, focus modes
│   ├── Reflections/              # Daily/weekly/monthly analytics
│   ├── Retention/                # Engagement, streaks, delight
│   └── README.md
│
├── Core/                          # Foundational engines shared by features
│   ├── BodyBattery/              # Energy scoring & trend analysis
│   ├── GoalManagement/           # Goal tracking & persona narratives
│   ├── VapiIntegration/          # Voice/text conversation orchestration
│   └── README.md
│
├── Services/                      # External platform integrations
│   ├── HealthKit/                # Sleep, HRV, activity data
│   ├── Calendar/                 # Event and agenda integration
│   ├── ScreenTime/               # Focus modes, app blocking
│   ├── Camera/                   # Photo capture for nutrition
│   ├── Notifications/            # Local & push notifications
│   └── README.md
│
├── Data/                          # Persistence layer
│   ├── Models/                   # Core data structures
│   ├── Persistence/              # SwiftData/CoreData setup
│   ├── Repository/               # Data access patterns
│   └── README.md
│
├── UI/                            # SwiftUI components & screens
│   ├── Screens/                  # Full-screen views per feature
│   ├── Components/               # Reusable SwiftUI components
│   ├── Theme/                    # Design system & styling
│   └── README.md
│
├── Utils/                         # Utilities & helpers
│   ├── Helpers/                  # Business logic helpers
│   ├── Extensions/               # Swift extensions
│   ├── Constants/                # App-wide constants
│   └── README.md
│
├── Resources/                     # Static assets
│   ├── Localizable.strings       # i18n strings
│   ├── Assets.xcassets/          # Images, colors, icons
│   └── README.md
│
├── ContentView.swift             # App root view
├── WelnessHackApp.swift          # App entry point
└── Assets.xcassets/              # XCode asset catalog
```

---

## Quick Reference

### For Feature Implementation
Navigate to `/WelnessHack/Features/{FeatureName}/`
- Create `Screens/` for views
- Create `Models/` for feature-specific data
- Create `Services/` for feature-specific logic
- Reference `Core/` engines for shared business logic

### For Core Engine Work
Navigate to `/WelnessHack/Core/{EngineName}/`
- **BodyBattery**: Sleep/HRV/activity aggregation
- **GoalManagement**: Goal tracking & identity narratives
- **VapiIntegration**: Vapi API client & session management

### For Data Needs
Navigate to `/WelnessHack/Data/`
- **Models/**: Define data structures in Swift
- **Persistence/**: Configure SwiftData schemas
- **Repository/**: Implement data access patterns

### For Service Integration
Navigate to `/WelnessHack/Services/{ServiceName}/`
- **HealthKit**: HealthKitProvider protocol
- **Calendar**: CalendarProvider protocol
- **ScreenTime**: ScreenTimeProvider protocol
- **Camera**: CameraProvider protocol
- **Notifications**: NotificationScheduler protocol

### For UI Components
Navigate to `/WelnessHack/UI/`
- **Screens/**: Complete views (HomeScreen, SettingsScreen, etc.)
- **Components/**: Reusable views (BodyBatteryCircle, ChartView, etc.)
- **Theme/**: Colors, typography, spacing, modifiers

---

## Documentation Files

All comprehensive documentation is in `/docs/`:

- **[docs/README.md](./docs/README.md)** - Start here! Overview and quick navigation
- **[docs/PROJECT_STRUCTURE.md](./docs/PROJECT_STRUCTURE.md)** - Detailed architecture, layering, and best practices
- **[docs/VAPI_INTEGRATION.md](./docs/VAPI_INTEGRATION.md)** - Vapi setup, API usage, context passing, tool integration
- **[docs/FEATURE_SLICING.md](./docs/FEATURE_SLICING.md)** - Each feature's requirements, deliverables, dependencies, and metrics
- **[docs/DATA_MODELS.md](./docs/DATA_MODELS.md)** - All data model specifications, persistence strategies, and repository patterns

---

## Naming Conventions

### Files & Classes
- One class/struct per file
- File name matches class name: `BodyBatteryEngine.swift`, `UserViewModel.swift`
- PascalCase for classes, structs, protocols
- camelCase for variables and functions

### Folders
- PascalCase: `BodyBattery/`, `VapiIntegration/`, `DailyFlow/`
- Plural for collections: `Services/`, `Features/`, `Models/`
- Descriptive: `FocusGuardian/` (not just `Focus/`)

### Protocols & Services
- Service protocols end with "Provider" or "Service": `HealthKitProvider`, `CalendarService`
- Repositories end with "Repository": `BodyBatteryRepository`, `MealRepository`
- ViewModels end with "ViewModel": `DailyFlowViewModel`, `NutritionViewModel`

---

## Dependency Flow

```
Features
├─ Depend on: Core + Services + Data + UI
├─ Examples: DailyFlow depends on BodyBattery, Calendar, VapiIntegration
└─ Can depend on: Other features minimally (prefer Core engines)

Core
├─ Depend on: Services + Data
├─ Provide: Shared business logic
└─ Examples: BodyBattery depends on HealthKit, Data layer

Services
├─ Depend on: Nothing
├─ Provide: Clean API protocols for platform features
└─ Examples: HealthKit, Calendar, ScreenTime

Data
├─ Depend on: Nothing (standalone)
├─ Provide: Models, persistence, repositories
└─ Used by: Core, Services, Features

UI
├─ Depend on: ViewModels from Features/Core
├─ Provide: Reusable components
└─ Used by: Features
```

---

## Development Workflow

### Adding a New Feature
```bash
1. Create folder: WelnessHack/Features/MyFeature/
2. Add subfolders: Screens/, Models/, Services/
3. Create: README.md with feature description
4. Update: docs/FEATURE_SLICING.md with requirements
5. Implement: Views, logic, data models
6. Add tests: Tests/MyFeatureTests/
```

### Modifying a Core Engine
```bash
1. Update: Core/{EngineName}/
2. Check: Which features depend on this?
3. Update: docs/DATA_MODELS.md if models changed
4. Test: Unit tests for logic
5. Integration: Test with dependent features
```

### Adding a Service Integration
```bash
1. Create: Services/{ServiceName}/
2. Define: Protocol with clean API
3. Implement: Concrete provider class
4. Add: Permission handling to Onboarding
5. Mock: Mock implementation for testing
```

---

## Key Features Breakdown

| Feature | Purpose | Main Integration |
|---------|---------|------------------|
| **Onboarding** | User setup, permissions, goals | HealthKit, Vapi |
| **DailyFlow** | Daily coaching, chat, reflection | BodyBattery, Vapi, Calendar |
| **Nutrition** | Food tracking with photo inference | Camera, Nutrition API |
| **FocusGuardian** | Work-life boundaries | ScreenTime, Notifications |
| **Reflections** | Analytics & insights | Data aggregation |
| **Retention** | Engagement & delight | Notifications, Vapi |

---

## Core Engines

### BodyBattery Engine
**Location**: `Core/BodyBattery/`

- Aggregates sleep, HRV, activity → energy score (0-100)
- Provides daily, weekly, monthly trends
- Generates recommendations based on score
- Powers all energy-related features

### GoalManagement Engine
**Location**: `Core/GoalManagement/`

- Tracks user goals and progress
- Manages "theater mental" identity narratives
- Aligns features with user goals
- Supports goal-based recommendations

### VapiIntegration Engine
**Location**: `Core/VapiIntegration/`

- Orchestrates Vapi voice/text calls
- Manages session state and message routing
- Passes context (body battery, goals, calendar)
- Executes recommended actions
- Handles errors and fallbacks

---

## Testing Strategy

### Unit Tests
- Core engines (scoring, logic)
- Repositories (CRUD)
- Helpers (formatting, calculations)

### Integration Tests
- Feature workflows (end-to-end)
- Service integrations (HealthKit fetch, etc.)
- Vapi message routing

### UI Tests
- Screen rendering and navigation
- Form input and validation
- Permission flows

### Mock Implementations
- MockVapiClient for Vapi testing
- MockHealthKitProvider for HealthKit testing
- MockRepository for data layer testing

---

## Getting Started

### New to the Project?
1. Read `docs/README.md`
2. Review `docs/PROJECT_STRUCTURE.md`
3. Pick a feature to understand in `docs/FEATURE_SLICING.md`
4. Reference `docs/DATA_MODELS.md` as needed

### Implementing a Feature?
1. Review feature section in `docs/FEATURE_SLICING.md`
2. Check dependencies and required data models
3. Create feature folder with proper structure
4. Implement views, logic, data models
5. Add tests
6. Update documentation

### Adding Core Logic?
1. Identify which engine to enhance
2. Update data models in `docs/DATA_MODELS.md`
3. Check dependent features
4. Implement and test thoroughly
5. Update documentation

---

## Best Practices

✅ **DO**
- Keep features independent
- Use Core engines for shared logic
- Define clear protocol boundaries for Services
- Write tests for new code
- Document changes in `/docs/`

❌ **DON'T**
- Have features depend directly on other features
- Skip permission handling
- Add tight coupling between layers
- Ignore error handling
- Forget to update documentation

---

## File Statistics

- **Total Directories**: 38
- **Feature Slices**: 6 (Onboarding, DailyFlow, Nutrition, FocusGuardian, Reflections, Retention)
- **Core Engines**: 3 (BodyBattery, GoalManagement, VapiIntegration)
- **Services**: 5 (HealthKit, Calendar, ScreenTime, Camera, Notifications)
- **Documentation Files**: 5 (README, PROJECT_STRUCTURE, VAPI_INTEGRATION, FEATURE_SLICING, DATA_MODELS)

---

## Next Steps

### Ready to Code?
1. Start with the Onboarding feature (simplest entry point)
2. Implement core data models from `Data/Models/`
3. Build HealthKit service integration
4. Create Vapi client in `Core/VapiIntegration/`
5. Build out features incrementally

### Need Help?
- Check `docs/` for comprehensive guides
- Review existing code patterns
- Test with mock implementations first
- Ask clarifying questions before implementing

---

**Created**: November 2025  
**Architecture**: Feature-sliced domain design with shared Core engines  
**Tech Stack**: SwiftUI, async/await, SwiftData, Vapi integration  
**Minimum iOS**: 15.0

