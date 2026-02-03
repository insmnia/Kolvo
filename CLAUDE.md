# Counts - iOS App

## Developer Contact

- **Email**: yaraslau.blonski@gmail.com
- **Telegram**: https://t.me/horekih
- **X (Twitter)**: https://x.com/horek1h

---

## Project Overview

A minimal iOS app for tracking meaningful numbers calmly. No streaks, goals, charts, or gamification. The design philosophy emphasizes calm, intentional interaction.

## Tech Stack

- **Platform**: iOS 17+
- **Language**: Swift
- **UI Framework**: SwiftUI
- **Architecture**: MVVM
- **Persistence**: Local JSON file (`counters.json` in Documents directory)
- **Dependencies**: None (intentionally dependency-free)

## File Structure

```
counts/
├── countsApp.swift              # App entry point, injects CountersViewModel
├── ContentView.swift            # Root view, displays HomeView
├── Models/
│   └── Counter.swift            # Data model, CounterType, TimeUnit enums
├── ViewModels/
│   ├── CountersViewModel.swift      # Main state: CRUD operations, free-tier limit
│   └── CounterDetailViewModel.swift # Detail screen logic, unit updates
├── Services/
│   └── PersistenceService.swift     # JSON read/write to Documents
├── Views/
│   ├── HomeView.swift           # Main list, NavigationStack, add/delete
│   ├── CounterCardView.swift    # Card component with live updates
│   ├── CreateCounterView.swift  # Modal form for new counters
│   ├── CounterDetailView.swift  # Detail screen with unit picker
│   └── AboutView.swift          # Developer contact info
└── Theme/
    └── Theme.swift              # Colors, animations, design tokens
```

## Data Model

### Counter
```swift
struct Counter: Identifiable, Codable {
    let id: UUID
    var name: String
    var type: CounterType      // .auto or .manual
    var createdAt: Date
    var startDate: Date        // For auto counters
    var manualValue: Int       // For manual counters
    var unit: TimeUnit?        // For auto counters
}
```

### CounterType
- `.auto` - Counts elapsed time from startDate
- `.manual` - User taps to increment

### TimeUnit
`seconds`, `minutes`, `hours`, `days`, `weeks`, `months`

Each unit has:
- `displayName` - Full name ("Minutes")
- `singularName` - Singular form ("minute")
- `shortName` - Abbreviated ("min")
- `calculate(from:to:)` - Elapsed time calculation
- `timerInterval` - Refresh rate for live updates

## Design System (Theme.swift)

### Colors (Warm Neutrals)
- `background` - Warm off-white (#FAF8F2)
- `cardBackground` - Soft cream (#F5F0E8)
- `textPrimary` - Warm dark brown (not black)
- `textSecondary` / `textTertiary` - Muted browns
- `accent` - Warm gray-brown
- `buttonBackground` - Dark warm gray
- `destructive` - Muted terracotta (not harsh red)

### Animations (Gentle Springs)
- `gentleSpring` - Main transitions (0.4s, 0.75 damping)
- `softSpring` - Slower, smoother (0.5s, 0.8 damping)
- `quickSpring` - Button feedback (0.3s, 0.7 damping)

### Button Styles
- `CardButtonStyle` - Scale 0.97 on press for cards
- `SoftButtonStyle` - Scale 0.95 + opacity for buttons

## Key Patterns

### State Management
- `CountersViewModel` is `@StateObject` in App, passed via `.environmentObject()`
- Detail views receive callbacks `onUpdate` / `onDelete` instead of environment

### Live Updates for Auto Counters
- Timer created in `onAppear`, invalidated in `onDisappear`
- Interval based on `TimeUnit.timerInterval`
- Updates wrapped in `withAnimation(Theme.softSpring)`

### Numeric Transitions
- Use `.contentTransition(.numericText())` for smooth number changes

### Haptic Feedback
- `.soft` for card increment button
- `.medium` for detail increment button

## Business Rules

### Free Tier
- Maximum 5 counters
- Attempting to add 6th shows calm info sheet (no upsell pressure)
- Check via `viewModel.canAddCounter`

## UI Conventions

- No emojis unless user requests
- No icons implying progress/achievement
- Soft rounded corners (12-16pt radius)
- Large numbers for values (36pt cards, 72pt detail)
- System font (SF Pro) throughout
- Neutral, calm tone in all copy

## Common Tasks

### Adding a new TimeUnit
1. Add case to `TimeUnit` enum in `Counter.swift`
2. Update all computed properties (`displayName`, `singularName`, `shortName`)
3. Add calculation logic in `calculate(from:to:)`
4. Set appropriate `timerInterval`

### Adding a new theme color
1. Add static property to `Theme.swift`
2. Use as `Theme.newColor` in views

### Modifying persistence
- All persistence goes through `PersistenceService.shared`
- Uses ISO8601 date encoding
- File location: Documents/counters.json

---

## Personal Rules

<!-- Add your personal preferences and rules below -->




