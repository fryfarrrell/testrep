# Architecture Overview

## Project Structure

```
lib/
├── app/                    # App-level configuration
│   ├── providers/          # Riverpod providers
│   └── theme/              # App theme
├── common/                 # Shared utilities
│   ├── utils/              # Helper functions
│   └── widgets/            # Reusable widgets
├── data/                   # Data layer
│   ├── api/               # External API clients
│   ├── local/              # Local storage
│   ├── models/             # Data models
│   └── repositories/       # Data repositories
├── domain/                 # Business logic
│   └── entities/           # Domain entities
└── features/               # Feature modules
    ├── splash/            # Splash screen
    ├── onboarding/        # Onboarding flow
    ├── main/              # Main app shell
    ├── map/               # Map screen
    ├── list/              # List screen
    ├── route12/           # 12-minute route
    ├── point_details/     # Point details
    └── settings/          # Settings screen
```

## Key Components

### State Management
- **Riverpod**: Used for state management and dependency injection
- Providers for: settings, location, places, cache service

### Data Sources
- **Overpass API**: Public OpenStreetMap API (no key required)
- **Hive**: Local caching and settings storage

### Features
1. **Splash Screen**: Initialization and first-run check
2. **Onboarding**: User introduction and location permission
3. **Map Screen**: Interactive map with markers and categories
4. **List Screen**: Sorted list of nearby places
5. **Route 12 Minutes**: Algorithm to generate walking routes
6. **Settings**: User preferences and cache management

## Adaptive Design

The app adapts to different screen sizes:
- **Mobile (< 768px)**: Bottom navigation, full-screen views
- **Tablet (≥ 768px)**: Navigation rail, split-view layouts

## Privacy

- No user accounts
- No location history stored
- All processing on device
- Anonymous API requests only
