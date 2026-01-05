# Setup Instructions

## Prerequisites

1. Flutter SDK (3.0.0 or higher)
2. Xcode (for iOS development)
3. CocoaPods

## Installation Steps

1. Install dependencies:
```bash
flutter pub get
```

2. Generate code (for Hive):
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

3. Configure Google Maps API Key:

   - Get a Google Maps API key from [Google Cloud Console](https://console.cloud.google.com/)
   - Add the key to `ios/Runner/AppDelegate.swift`:
   
   ```swift
   import GoogleMaps
   
   GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
   ```

   Or add to `ios/Runner/Info.plist`:
   ```xml
   <key>GMSApiKey</key>
   <string>YOUR_API_KEY_HERE</string>
   ```

4. Run the app:
```bash
flutter run
```

## iOS Configuration

The app requires location permissions. These are configured in `ios/Runner/Info.plist`:
- `NSLocationWhenInUseUsageDescription` - Required for location access

## Notes

- The app uses Overpass API (public, no key required)
- All data is cached locally using Hive
- No backend server required
- Works offline with cached data
