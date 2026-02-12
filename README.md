# Deteksi Daun Mobile App

Flutter mobile application for leaf detection using CNN and YOLO models connected to Flask backend.

## Features

- 📷 **Camera Integration** - Take photos directly from your device camera
- 🖼️ **Gallery Support** - Select images from your photo gallery
- 🤖 **Dual Model Support** - Choose between CNN classification or YOLO detection
- 📊 **Real-time Results** - Get instant leaf classification results
- 📱 **User Friendly UI** - Beautiful Material 3 design
- 🔄 **History** - View previous detection results

## Supported Leaf Types

- Daun Jeruk (Orange Leaf)
- Daun Kari (Curry Leaf)
- Daun Kunyit (Turmeric Leaf)
- Daun Pandan (Pandan Leaf)
- Daun Salam (Bay Leaf)

## Project Structure

```
mobile/
├── lib/
│   ├── app/
│   │   ├── config/          # Theme configuration
│   │   ├── models/          # Data models
│   │   ├── modules/         # Feature modules
│   │   │   ├── home/        # Home screen
│   │   │   ├── camera/      # Camera capture
│   │   │   ├── result/      # Results display
│   │   │   └── history/    # Detection history
│   │   ├── routes/          # App navigation
│   │   └── services/        # API services
│   └── main.dart
├── pubspec.yaml
└── README.md
```

## Prerequisites

- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher
- Android Studio / VS Code
- Running Flask backend server

## Installation

### 1. Install Flutter
Follow the official Flutter installation guide:
https://flutter.dev/docs/get-started/install

### 2. Clone and Setup
```bash
# Navigate to mobile directory
cd mobile

# Get dependencies
flutter pub get
```

### 3. Configure Flask Backend
Make sure your Flask server is running. The default URL is `http://localhost:5000`.

To change the API URL, edit `lib/app/services/api_service.dart`:
```dart
static const String baseUrl = 'http://YOUR_SERVER_IP:5000';
```

### 4. Run the App
```bash
# Run on connected device/emulator
flutter run

# Run on specific platform
flutter run -d android
flutter run -d ios
```

## API Endpoints Used

The mobile app connects to these Flask API endpoints:

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/predict` | POST | Unified prediction (auto-detect model) |
| `/predict/cnn` | POST | CNN classification only |
| `/predict/yolo` | POST | YOLO detection only |
| `/health` | GET | Health check |
| `/classes` | GET | Get list of supported classes |

## Configuration

### Android
Add internet permission in `android/app/src/main/AndroidManifest.xml`:
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.CAMERA"/>
    ...
</manifest>
```

### iOS
Add camera usage description in `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to take photos of leaves for detection.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to select leaf images.</string>
```

## Dependencies

Key packages used:
- `get` - State management and navigation
- `dio` - HTTP client
- `image_picker` - Camera and gallery access
- `google_fonts` - Beautiful typography
- `intl` - Date formatting
- `shared_preferences` - Local storage

## Running on Physical Devices

For Android:
1. Enable Developer Options and USB Debugging on your device
2. Connect device via USB
3. Run `flutter devices` to verify connection
4. Run `flutter run`

For iOS:
1. Open `ios/Runner.xcworkspace` in Xcode
2. Configure signing team
3. Build and run from Xcode or `flutter run`

## Troubleshooting

### API Connection Issues
- Ensure Flask server is running
- Check IP address for physical device testing (localhost won't work)
- Verify firewall settings

### Camera Issues
- Check camera permissions in app settings
- Ensure no other app is using the camera

### Build Errors
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

## Development

### Adding New Features
1. Create new module in `lib/app/modules/`
2. Add routes in `lib/app/routes/app_pages.dart`
3. Update navigation as needed

### Code Style
Follow Dart style guide: https://dart.dev/guides/language/effective-dart

## License

This project is part of a thesis research on leaf detection using CNN and YOLO.

## Credits

- Flask Backend: `Deteksi-Daun-Yolo-Vs-CNN/`
- YOLOv11 Model for leaf detection
- CNN Model for leaf classification
