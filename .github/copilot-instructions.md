# Copilot Instructions for Harmony Music

## Project Overview

Harmony Music is a cross-platform music streaming application built with Flutter, supporting Android, Windows, and Linux. The app streams music from YouTube/YouTube Music without requiring login or showing advertisements.

## Technology Stack

- **Framework**: Flutter 3.24.2+ (Dart SDK >=3.1.5 <4.0.0)
- **State Management**: GetX (get: ^4.7.1)
- **Audio Playback**:
  - Android: just_audio (^0.9.46)
  - Linux/Windows: media_kit via just_audio_media_kit
  - Background audio: audio_service (^0.18.17)
- **Local Storage**: Hive (^2.2.3) with hive_flutter
- **YouTube API**: youtube_explode_dart (custom fork)
- **HTTP Client**: dio (^5.7.0)
- **UI Components**: animations, cached_network_image, flutter_slidable, shimmer

## Project Structure

```
lib/
├── base_class/      # Base classes and abstractions
├── mixins/          # Reusable mixins
├── models/          # Data models
├── native_bindings/ # Platform-specific native code bindings
├── services/        # Business logic services (audio, music, downloader, piped)
├── ui/              # User interface
│   ├── player/      # Music player UI and controllers
│   ├── screens/     # App screens (Home, Library, Settings, Search)
│   ├── utils/       # UI utilities (theme controller)
│   └── widgets/     # Reusable widgets
└── utils/           # General utilities and helpers
```

## Key Controllers (GetX)

- `PlayerController` - Manages music playback
- `HomeScreenController` - Home screen state
- `LibraryController` - Library/collection management
- `SettingsScreenController` - App settings
- `SearchScreenController` - Search functionality
- `ThemeController` - Dynamic theming

## Architecture Patterns

- **State Management**: GetX pattern with controllers
- **Dependency Injection**: GetX dependency injection (`Get.put`, `Get.find`)
- **Services**: Centralized service classes for audio, music fetching, and downloads
- **Mixins**: Used for code reuse across controllers

## Development Workflow

### Setup
```bash
flutter pub get
```

### Linting
```bash
flutter analyze
```

### Building
```bash
# Android
flutter build apk

# Windows
flutter build windows

# Linux
flutter build linux
```

### Testing
```bash
flutter test
```

## Coding Guidelines

1. **Follow Dart/Flutter best practices**:
   - Use `flutter_lints` package rules (already configured)
   - Follow the official Dart style guide
   - Maintain consistent code formatting

2. **State Management**:
   - Use GetX controllers for state management
   - Use `Get.put()` for controller initialization
   - Use `Get.find()` to access existing controllers
   - Controllers should be placed in their respective screen directories

3. **File Organization**:
   - Keep related files together (screen + controller)
   - Place reusable widgets in `ui/widgets/`
   - Place business logic in `services/`
   - Keep models in `models/`

4. **Platform Considerations**:
   - Use `GetPlatform.isAndroid`, `GetPlatform.isDesktop`, etc. for platform-specific code
   - Android uses just_audio, Desktop uses media_kit
   - Consider mobile vs desktop UI patterns

5. **Assets and Resources**:
   - Icons are located in `assets/icons/`
   - Localization files are in `localization/`
   - Use the GetX translation system (`Languages()`)

6. **Dependencies**:
   - Several packages use custom forks (youtube_explode_dart, just_audio_media_kit, etc.)
   - Be cautious when suggesting package updates
   - Check pubspec.yaml for git-based dependencies

## Important Considerations

1. **No Login Required**: The app operates without user authentication
2. **Ad-Free**: No advertisement integration
3. **GPL v3.0 License**: Code must remain open source
4. **Third Party Content**: Be mindful of copyright and content usage
5. **Cross-Platform**: Changes should consider all target platforms (Android, Windows, Linux)
6. **Offline Support**: App caches songs and supports offline playback
7. **Background Playback**: Audio service integration for background music

## Common Tasks

### Adding a New Screen
1. Create screen file in `lib/ui/screens/[ScreenName]/`
2. Create corresponding controller extending `GetxController`
3. Register controller with GetX
4. Add navigation route if needed

### Adding a New Feature
1. Consider platform support (mobile vs desktop)
2. Update relevant services if needed
3. Create/update models as needed
4. Update UI components
5. Test on target platforms

### Modifying Audio Playback
- Audio logic is in `services/audio_handler.dart`
- Player UI in `ui/player/`
- Platform-specific implementations via just_audio or media_kit

## CI/CD

- Linting and build checks run on PRs via `.github/workflows/code_quality.yml`
- APK builds are automated
- Windows executable builds have separate workflow

## Testing

- Widget tests are in `test/` directory
- Follow existing test patterns when adding new tests
- Use Flutter's widget testing framework

## Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [GetX Documentation](https://pub.dev/packages/get)
- [Hive Documentation](https://docs.hivedb.dev/)
- Project README.md for feature list and credits
