# WelnessHack Project Structure

## Overview

WelnessHack is an iOS AI Life Coach application powered by Vapi for voice/text conversations. The architecture uses vertically sliced features, each delivering end-to-end value while sharing a common core engine and data layer.

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   Features (UI Layer)                   │
├─────────────────────────────────────────────────────────┤
│  Onboarding │ DailyFlow │ Nutrition │ FocusGuardian   │
│  Reflections │ Retention │                               │
├─────────────────────────────────────────────────────────┤
│                   Core (Business Logic)                  │
├─────────────────────────────────────────────────────────┤
│  BodyBattery │ GoalManagement │ VapiIntegration        │
├─────────────────────────────────────────────────────────┤
│                 Services (Platform APIs)                 │
├─────────────────────────────────────────────────────────┤
│  HealthKit │ Calendar │ ScreenTime │ Camera │ Notify   │
├─────────────────────────────────────────────────────────┤
│                   Data (Persistence)                     │
├─────────────────────────────────────────────────────────┤
│  Models │ Persistence │ Repository                      │
├─────────────────────────────────────────────────────────┤
│                   UI & Utilities                          │
├─────────────────────────────────────────────────────────┤
│  Screens │ Components │ Theme │ Helpers │ Extensions   │
└─────────────────────────────────────────────────────────┘
```

## Directory Map

### WelnessHack/ (Main Bundle)
- **Features/** - Vertically sliced feature modules
- **Core/** - Foundational engines (BodyBattery, Goals, Vapi)
- **Services/** - External integrations (HealthKit, Calendar, etc.)
- **Data/** - Models, persistence, repositories
- **UI/** - Screens, components, theming
- **Utils/** - Helpers, extensions, constants
- **Resources/** - Static assets and localization
- **Assets.xcassets/** - Image and color assets

### docs/
- **PROJECT_STRUCTURE.md** (this file) - Architecture overview
- **VAPI_INTEGRATION.md** - Vapi setup and usage patterns
- **FEATURE_SLICING.md** - Feature breakdown and dependency map
- **DATA_MODELS.md** - Core data structure specifications

## Feature Slicing Strategy

Each feature is designed as a vertical slice containing:

1. **Feature-specific UI** - Screens and components for that feature
2. **Feature logic** - Coordinated with Core engines
3. **Feature data** - Models and repository queries
4. **Feature services** - Integration with external platforms as needed

### Feature Inventory

| Feature | Purpose | Primary Integration |
|---------|---------|---------------------|
| Onboarding | User setup, permissions, goal selection | HealthKit, Vapi |
| DailyFlow | Morning briefing, Vapi chat, energy tracking | All services |
| Nutrition | Food capture, analysis, meal logging | Camera, inference |
| FocusGuardian | Work-life boundaries, app blocking | ScreenTime |
| Reflections | Nightly/weekly/monthly insights | Data aggregation |
| Retention | Motivation, delight, streak tracking | Vapi, notifications |

## Core Systems

### BodyBattery Engine
Aggregates sleep, HRV, and activity data into a 0-100 energy score. Provides:
- Real-time score updates
- Trend analysis and prediction
- Intervention recommendations when energy dips
- Historical tracking for patterns

### GoalManagement
Tracks user goals, persona, and identity narratives:
- Goal selection (burnout prevention, discipline, nutrition, etc.)
- Theater mental visualization prompts
- Progress measurement against goals
- Identity reinforcement messaging

### VapiIntegration
Orchestrates voice and text conversations:
- Vapi API client for call initiation
- Session context management
- Message routing and action triggering
- Call history and transcript persistence
- Fallback and error handling

## Data Flow

```
Health Data (HealthKit)
├─► Body Battery Engine
│   └─► Energy Score (0-100)
│       └─► Daily Metrics & Charts
└─► Notifications (break recommendations)

Calendar Events
├─► Workload Analysis
│   └─► Vapi Context (agenda for chatbot)
└─► Focus Mode Scheduling

Vapi Conversations
├─► Emotion Detection
├─► Pattern Recognition
│   └─► Coaching Insights
└─► Action Triggers
    ├─► Notifications
    ├─► Focus Mode Changes
    └─► Reflection Analytics

Meals & Photos
├─► Nutrition Inference
│   └─► Macro/Micro Analysis
└─► Health Impact Scoring
```

## Dependency Hierarchy

```
Features (depend on Core + Services)
├─ Onboarding
├─ DailyFlow (depends on BodyBattery, VapiIntegration, HealthKit, Calendar)
├─ Nutrition (depends on Camera, inference service)
├─ FocusGuardian (depends on ScreenTime, notifications)
├─ Reflections (depends on Data aggregation)
└─ Retention (depends on Notifications, Vapi)

Core (depend on Services + Data)
├─ BodyBattery (depends on HealthKit service)
├─ GoalManagement (depends on Data persistence)
└─ VapiIntegration (depends on Vapi API)

Services (no interdependencies)
├─ HealthKit
├─ Calendar
├─ ScreenTime
├─ Camera
└─ Notifications

Data (standalone)
├─ Models
├─ Persistence
└─ Repository
```

## Best Practices

### File Organization
- One class/struct per file (with few exceptions for small related types)
- File name matches class name (PascalCase)
- Keep files under 400 lines; split if larger
- Use MARK: comments to organize large files

### Naming Conventions
- Protocols: PascalCase with suffix "Protocol" or "Service" (e.g., `HealthKitProvider`)
- ViewModels: Suffix with "ViewModel" (e.g., `DailyFlowViewModel`)
- Repositories: Suffix with "Repository" (e.g., `BodyBatteryRepository`)
- Constants: UPPER_SNAKE_CASE for static values

### Data Dependencies
- Features should depend on Core engines, not directly on Services
- Services should expose clean protocols for easier mocking
- Data layer provides repository pattern for abstraction

### Feature Independence
- Each feature should compile independently with mock dependencies
- Minimize cross-feature imports
- Use shared Core engines for common operations

## Swift Compatibility

- **Minimum Deployment Target**: iOS 15.0 (for async/await, SwiftUI stability)
- **Swift Version**: 5.9 or later
- **Architecture**: Supports arm64 and x86_64

## Localization & Internationalization

- All user-facing strings in Localizable.strings
- Feature-specific strings in feature bundles
- RTL language support via SwiftUI's built-in features

## Testing Strategy

Each module should have a corresponding test target:
- Unit tests for Core engines and Services
- UI tests for Screens using dependency injection
- Integration tests for feature flows with mock Vapi responses

