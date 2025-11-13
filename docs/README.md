# WelnessHack Documentation

Welcome to the WelnessHack project documentation. This directory contains comprehensive guides for understanding the architecture, feature structure, and implementation details of the AI Life Coach application.

## Quick Navigation

### [PROJECT_STRUCTURE.md](./PROJECT_STRUCTURE.md)
**Start here** if you're new to the project. Covers:
- Overall architecture and layering
- Directory organization
- Feature slicing strategy
- Dependency hierarchy
- Best practices

### [VAPI_INTEGRATION.md](./VAPI_INTEGRATION.md)
Deep dive into Vapi integration. Includes:
- Core Vapi concepts (sessions, messages, actions)
- Setup and configuration
- Message routing and context passing
- Tool integration patterns
- Error handling and recovery
- Privacy and compliance

### [FEATURE_SLICING.md](./FEATURE_SLICING.md)
Complete breakdown of each feature slice. For each feature:
- User flow and journey
- Deliverables and components
- Data models created
- Dependencies and integrations
- Success metrics

Features covered:
1. **Onboarding** - Initial setup and goal selection
2. **DailyFlow** - Morning briefing, coaching, evening reflection
3. **Nutrition** - Photo-based meal tracking and analysis
4. **FocusGuardian** - Work-life boundaries and focus modes
5. **Reflections** - Daily, weekly, and monthly analytics
6. **Retention** - Engagement, streaks, and delight moments

### [DATA_MODELS.md](./DATA_MODELS.md)
Specification of all core data models. Includes:
- User, Goal, BodyBattery models
- Conversation and Message structures
- Habit tracking models
- Report models (daily, weekly, monthly)
- Repository patterns
- Persistence strategy

---

## Architecture Overview

```
┌─────────────────────────────────────────────┐
│             Features (UI)                   │
│  Onboarding │ DailyFlow │ Nutrition │ ...  │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────┴──────────────────────────┐
│            Core Engines                     │
│  BodyBattery │ Goals │ VapiIntegration     │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────┴──────────────────────────┐
│           Services (APIs)                   │
│ HealthKit │ Calendar │ ScreenTime │ ...    │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────┴──────────────────────────┐
│         Data Layer (Persistence)            │
│    Models │ Persistence │ Repository       │
└─────────────────────────────────────────────┘
```

---

## Key Concepts

### Vertical Slicing
Each feature is a **complete vertical slice** containing:
- UI/screens specific to that feature
- Feature-specific business logic
- Feature data models and storage
- Integration with core engines and services

Benefits:
- Independent delivery and testing
- Clear dependencies
- Incremental value delivery
- Easier to understand and maintain

### Core Engines
Shared across all features:

**BodyBattery** - Energy score aggregation
- Combines sleep, HRV, activity data
- Generates 0-100 energy score
- Provides recommendations and trends

**GoalManagement** - Goal tracking and persona
- Stores user goals and progress
- Manages "theater mental" identity narrative
- Aligns features with user goals

**VapiIntegration** - Vapi orchestration
- Session and message management
- Context passing to Vapi
- Action trigger execution

### Services
Encapsulated integrations:
- HealthKit, Calendar, ScreenTime, Camera, Notifications
- Each has a clean protocol interface
- Mocks available for testing

---

## Getting Started

### For New Developers
1. Read [PROJECT_STRUCTURE.md](./PROJECT_STRUCTURE.md) for overview
2. Explore [FEATURE_SLICING.md](./FEATURE_SLICING.md) to understand what you're building
3. Check [DATA_MODELS.md](./DATA_MODELS.md) to understand data flow
4. Review [VAPI_INTEGRATION.md](./VAPI_INTEGRATION.md) for Vapi patterns

### For Feature Implementation
1. Pick a feature from the roadmap
2. Review the feature section in [FEATURE_SLICING.md](./FEATURE_SLICING.md)
3. Identify required data models in [DATA_MODELS.md](./DATA_MODELS.md)
4. Check dependencies and core engine usage
5. Implement within the feature folder structure

### For Core Engine Work
1. Review affected models in [DATA_MODELS.md](./DATA_MODELS.md)
2. Check which features depend on your changes
3. Update [FEATURE_SLICING.md](./FEATURE_SLICING.md) if dependencies change
4. Ensure backward compatibility with existing features

### For Vapi Integration
1. Read [VAPI_INTEGRATION.md](./VAPI_INTEGRATION.md) thoroughly
2. Understand context passing and message routing
3. Implement tool handlers for new actions
4. Test with mock Vapi responses
5. Verify error handling and fallbacks

---

## Development Workflow

### Adding a New Feature
1. Create feature folder under `/WelnessHack/Features/{FeatureName}/`
2. Add Screens, Models, and Services subfolders as needed
3. Create README in feature root
4. Implement views and logic
5. Add to data layer (models + repository)
6. Update [FEATURE_SLICING.md](./FEATURE_SLICING.md) if not documented
7. Add tests for logic and UI

### Modifying Data Models
1. Update model in `Data/Models/`
2. Update migration in `Data/Persistence/` if needed
3. Update repository in `Data/Repository/`
4. Update [DATA_MODELS.md](./DATA_MODELS.md)
5. Check affected features and update if necessary

### Enhancing Vapi Integration
1. Define new Vapi action or message type
2. Add handler in VapiIntegration
3. Update context if needed
4. Add tool definition to Vapi dashboard
5. Update [VAPI_INTEGRATION.md](./VAPI_INTEGRATION.md)
6. Test with mock Vapi client

---

## Testing Strategy

### Unit Tests
- Core engines (BodyBattery scoring, Goal logic)
- Repositories (CRUD operations)
- Helpers and utilities
- Data transformations

### Integration Tests
- Service integrations (HealthKit, Calendar)
- Feature workflows (end-to-end user flows)
- Vapi message routing
- Data persistence

### UI Tests
- Screen rendering and navigation
- Form input and validation
- Permission flows
- Vapi screen interactions

---

## Release Process

1. Feature complete and tested
2. Add to sprint in [FEATURE_SLICING.md](./FEATURE_SLICING.md) roadmap
3. Update data models if changed
4. Verify dependencies and core engine changes
5. Run full test suite
6. Code review
7. Merge to main
8. Build and release to TestFlight
9. Update release notes with new features

---

## Common Questions

**Q: How do I add a new permission?**
A: Update onboarding flow in `Features/Onboarding/`, handle in corresponding service (HealthKit, Camera, etc.), and document in [FEATURE_SLICING.md](./FEATURE_SLICING.md).

**Q: How does Vapi context get passed?**
A: See VapiIntegration in [VAPI_INTEGRATION.md](./VAPI_INTEGRATION.md). Context includes battery, mood, calendar, goals. Updated before each call.

**Q: Can I modify data models?**
A: Yes, but handle migration in persistence layer, update all dependent features, and test thoroughly.

**Q: How do I test Vapi without hitting real API?**
A: Use MockVapiClient in tests. See [VAPI_INTEGRATION.md](./VAPI_INTEGRATION.md) for examples.

**Q: Where do I add localization?**
A: Create Localizable.strings in Resources/, use NSLocalizedString() in code. Feature-specific strings can go in feature bundle.

---

## Resources

- **Vapi Docs**: https://docs.vapi.ai
- **HealthKit Guide**: https://developer.apple.com/documentation/healthkit
- **SwiftUI**: https://developer.apple.com/xcode/swiftui/
- **SwiftData**: https://developer.apple.com/documentation/swiftdata
- **Async/Await**: https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html

---

## Contributing

- Follow architecture patterns described in this documentation
- Keep features independent and well-defined
- Update documentation when adding new concepts
- Write tests for new features
- Request code review before merging

---

Last Updated: November 2025

