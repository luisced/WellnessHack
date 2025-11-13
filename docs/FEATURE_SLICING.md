# Feature Slicing Strategy

## Principles

Each feature is designed as a **vertical slice**, meaning:
- **Complete End-to-End Value**: Users can derive value from the feature in isolation
- **Minimal Dependencies**: Core engines shared; external service dependencies isolated
- **Independent Testing**: Can test and deploy features separately
- **Incremental Delivery**: Build and release features in priority order

## Feature Breakdown

### 1. Onboarding
**Value Proposition**: Get users setup with permissions, goals, and initial coaching

**User Flow**:
1. App launch → Permission requests
2. Select goals from preset list
3. Set persona/"theater mental" narrative
4. Initial body battery calibration
5. Meet Vapi coach introduction
6. First coaching message

**Deliverables**:
- OnboardingView (multi-step wizard)
- PermissionManager (coordinate all requests)
- GoalSelectionView
- VapiIntroductionScreen
- Vapi context setup for initial call

**Data Created**:
- User profile and goal list
- Initial body battery baseline
- Permission audit log

**Dependencies**:
- HealthKit (sleep/HRV baseline)
- GoalManagement engine
- VapiIntegration engine
- Notifications (permission)

**Success Metrics**:
- Completion rate (% reaching end)
- Time to complete
- Permission grant rate
- First Vapi call success rate

---

### 2. Daily Flow
**Value Proposition**: Morning briefing, real-time coaching, evening reflection

**User Flow**:

**Morning (6-9 AM)**:
1. User opens app or notification
2. Morning briefing appears: body battery, calendar, motivational message
3. Quick Vapi call for "How's your energy?"

**During Day (9 AM-6 PM)**:
1. User asks Vapi questions ("I'm tired", "What should I eat?")
2. Vapi analyzes context (battery, calendar, mood)
3. Recommendations delivered (break, meditation, focus mode)
4. User confirms or rejects action

**Evening (6-9 PM)**:
1. Daily reflection hub shows: battery curve, habits, emotions
2. Nightly narrative generated
3. Next day preview

**Deliverables**:
- HomeScreen (dashboard)
- VapiChatScreen (voice/text interface)
- DailyBriefingCard component
- MorningBriefingGenerator (compose message)
- DailyMetricsCompiler
- EveningReflectionView

**Data Created**:
- Conversation messages
- Mood/emotion detections
- Habit tracking snapshots
- Daily metrics snapshots

**Dependencies**:
- BodyBattery engine (score + trends)
- HealthKit (updated metrics)
- Calendar (agenda)
- VapiIntegration (coach calls)
- Notifications (morning alert)
- Reflections feature (evening data)

**Success Metrics**:
- Daily active users
- Vapi calls per user per day
- Message count
- Feature adoption %
- Engagement time

---

### 3. Nutrition
**Value Proposition**: Photo-to-benefit meal logging with personalized guidance

**User Flow**:
1. User taps "Log Meal"
2. Capture photo of food
3. AI infers meal composition
4. Display nutritional benefits (macros, stability duration, health impact)
5. Save meal entry
6. Ask Vapi for healthy alternatives or future recommendations

**Deliverables**:
- NutritionScreen (dashboard)
- MealPhotoCapture (camera + upload)
- NutritionAnalysisView (benefits display)
- MealCard component
- MealHistoryView
- NutritionAnalyzer (call inference service)

**Data Created**:
- Meal entries with photos and metadata
- Inferred nutrition facts
- User meal preferences
- Macro/micro patterns

**Dependencies**:
- Camera service (photo capture)
- Nutrition inference API (external)
- MealRepository (storage)
- VapiIntegration (ask for alternatives)
- BodyBattery (energy stability estimates)

**Success Metrics**:
- Meals logged per user per week
- Inference accuracy
- Feature usage rate
- Vapi follow-up question rate

---

### 4. Focus Guardian
**Value Proposition**: Smart work-life boundaries enforced through focus modes and app blocking

**User Flow**:

**Setup**:
1. User sets work hours (e.g., 9 AM-5 PM, 1-2 PM lunch break)
2. Selects work apps to block during off-hours
3. Chooses focus mode intensity (light/deep)

**Daily Execution**:
1. At work hour start: Vapi message + enable focus mode
2. During work: Gentle reminders if checking personal apps
3. At break time: Transition message, suggest break activities
4. At end of work: Celebration message, offer evening focus transition

**Deliverables**:
- FocusSetupScreen (configure work hours & apps)
- FocusScheduleView (weekly grid)
- FocusActiveScreen (active mode display)
- TransitionMessagesService (positive reinforcement)
- FocusModeManager (ScreenTime integration)

**Data Created**:
- Work schedule definition
- App block list
- Focus mode transitions log
- Boundary adherence metrics

**Dependencies**:
- ScreenTime service (app blocking + focus modes)
- NotificationScheduler (timing)
- VapiIntegration (messaging)
- BodyBattery (energy context)

**Success Metrics**:
- Setup completion rate
- Focus mode activation rate
- App block trigger rate
- Adherence to schedule
- User satisfaction with boundaries

---

### 5. Reflections
**Value Proposition**: Multi-scale (daily/weekly/monthly) analytics and personal insights

**Nightly Reflection (Daily)**:
- Energy curve chart
- Habit completion checklist
- Emotional words detected
- Sleep quality preview
- Next day preview

**Weekly Report (Sundays)**:
- 7-day energy trend
- Habits completed vs. attempted
- Emotional trend analysis (anxiety down %, positivity up %)
- Focus mode compliance
- Meal quality score
- Personal growth narrative

**Monthly Review (End of month)**:
- 30-day trends
- Productivity hours vs. rest hours
- Burnout risk assessment
- Habit adoption rate
- Dietary improvements
- Emotional resilience gains
- Personal identity reinforcement

**Deliverables**:
- DailyReflectionView (evening hub)
- WeeklyReportView (Sunday sheet)
- MonthlyReportView (end of month)
- ChartComponents (line, bar, progress)
- ReportDataCompiler (aggregate metrics)
- ReportNarrativeGenerator (personalized text)

**Data Created**:
- Daily/weekly/monthly aggregates
- Trend objects
- Report narratives
- User insights

**Dependencies**:
- BodyBatteryRepository (energy data)
- ConversationRepository (emotion detection)
- HabitRepository (completion tracking)
- HealthKit (sleep metrics)
- Data aggregation utilities

**Success Metrics**:
- Report view rate
- Report completion (scroll through full report)
- Insight implementation rate
- User satisfaction scores
- Saved/shared report rate

---

### 6. Retention
**Value Proposition**: Delight, surprise, and motivation to keep users engaged

**Mechanisms**:

**Streaks & Milestones**:
- Day 7, 30, 90, 365 streaks with unlock celebrations
- Habit combo bonuses (did 3 habits in a row)
- Energy consistency badges

**Motivational Nudges**:
- Random morning messages: "Today you take a decision your future self will thank you for"
- Streak reminders: "10 days since you talked yourself down. Proud of you."
- Behavioral reinforcement: "You chose rest today. That's discipline."

**Contextual Easter Eggs**:
- Detect mood from conversation, respond with humor
- Energy pattern recognition, offer personalized affirmations
- Habit completions trigger fun reactions

**Referral & Social**:
- Share weekly reports with friends (optional)
- Referral codes for new users
- Social proof notifications

**Deliverables**:
- MilestoneUnlockView (celebration modal)
- StreakTrackerComponent
- MotivationalNudgeService (schedule + compose)
- ReportShareSheet
- RewardAnimations (Lottie or SwiftUI)
- RetentionAnalyticsTracker

**Data Created**:
- Streak records
- Milestone completion history
- Nudge engagement logs
- Share events

**Dependencies**:
- Notifications (delivery)
- ConversationRepository (mood analysis)
- HabitRepository (streak tracking)
- AnalyticsService (tracking)

**Success Metrics**:
- Week 2 retention rate
- Week 4 retention rate
- Daily active users (DAU)
- Monthly active users (MAU)
- Nudge engagement rate
- Share rate

---

## Dependency Map

```
Retention
├─ Notifications
├─ ConversationRepository
├─ HabitRepository
└─ AnalyticsService

Reflections
├─ BodyBatteryRepository
├─ ConversationRepository
├─ HabitRepository
├─ HealthKit
└─ Data utilities

FocusGuardian
├─ ScreenTime
├─ NotificationScheduler
├─ VapiIntegration
└─ BodyBattery

Nutrition
├─ Camera
├─ Nutrition API
├─ MealRepository
├─ VapiIntegration
└─ BodyBattery

DailyFlow
├─ BodyBattery
├─ HealthKit
├─ Calendar
├─ VapiIntegration
├─ Notifications
└─ Reflections (evening)

Onboarding
├─ HealthKit
├─ GoalManagement
├─ VapiIntegration
└─ Notifications

Core Engines (no feature deps)
├─ BodyBattery → HealthKit
├─ GoalManagement → Data
└─ VapiIntegration → Vapi API

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

## Implementation Roadmap

### Sprint 1: Foundation
- Data models and persistence layer
- BodyBattery engine
- HealthKit integration
- VapiIntegration client

**Output**: Core infrastructure ready for features

### Sprint 2: Getting Started
- Onboarding feature (goals, permissions, intro)
- Home screen skeleton
- Initial Vapi call setup

**Output**: Users can start using app with clear goals

### Sprint 3: Daily Coaching
- DailyFlow feature (morning briefing, evening reflection)
- Vapi chat screen and message history
- Emotion detection basics

**Output**: Users get daily coach experience

### Sprint 4: Life Boundaries
- FocusGuardian feature (work schedules, app blocking)
- Transition messaging
- Focus mode automations

**Output**: Users experience work-life balance

### Sprint 5: Nutrition
- Nutrition feature (photo capture, inference, logging)
- Meal history and patterns
- Body battery integration

**Output**: Users can track meals and receive guidance

### Sprint 6: Insights
- Reflections feature (nightly, weekly, monthly)
- Charts and trend analysis
- Personal growth narratives

**Output**: Users see patterns and progress

### Sprint 7: Engagement
- Retention feature (streaks, milestones, nudges)
- Easter eggs and delight moments
- Sharing capabilities

**Output**: Users stay engaged long-term

---

## Testing Strategy by Feature

### Unit Tests
- Core engines (BodyBattery scoring, GoalManagement logic)
- Repositories (CRUD operations)
- Data transformations
- Helper functions

### Integration Tests
- Service integrations (HealthKit sync, Calendar fetch)
- Feature workflows (end-to-end user flows)
- Vapi message routing
- Data persistence

### UI Tests
- Screen rendering and navigation
- Form input and submission
- Chart rendering accuracy
- Permission flows

### Manual QA
- Vapi conversation quality
- Notification timing and content
- Focus mode transitions
- Photo inference accuracy

