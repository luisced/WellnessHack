# Data

Data layer managing models, persistence, and repositories.

## Directory Structure

### Models
Core data models:
- `User.swift` - User profile and preferences
- `BodyBattery.swift` - Energy score snapshots
- `DailyMetrics.swift` - Daily aggregated metrics
- `Goal.swift` - User goals and tracking
- `Meal.swift` - Food entries and nutrition data
- `Conversation.swift` - Vapi chat history and transcripts
- `Habit.swift` - Habit definitions and completions
- `WeeklyReport.swift` - Aggregated weekly insights
- `MonthlyReport.swift` - Aggregated monthly insights

### Persistence
Local storage and database:
- SwiftData or CoreData models
- Database initialization and migration
- Data backup and recovery
- Privacy-compliant storage strategies

### Repository
Data access patterns:
- `UserRepository.swift` - User data CRUD
- `BodyBatteryRepository.swift` - Energy metrics queries
- `MealRepository.swift` - Food history retrieval
- `ConversationRepository.swift` - Chat history management
- `HabitRepository.swift` - Habit tracking queries

