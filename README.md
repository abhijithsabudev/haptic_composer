# Haptic Composer

🎯 **Design custom haptic experiences as easily as composing music** - make your app feel as good as it looks.


## Features

✨ **Easy to Use** - Simple, intuitive API for adding haptic feedback to your Flutter app

🎼 **Composable Patterns** - Build complex haptic patterns from simple building blocks

🎨 **Visual Composer** - Interactive UI for designing and testing haptic patterns

📦 **Pre-built Presets** - 25+ carefully designed haptic patterns ready to use

🔧 **Flexible** - From simple one-line feedback to complex choreographed sequences

📱 **Cross-Platform** - iOS (Core Haptics) and Android (VibrationEffect) support

💾 **Serializable** - Save and load patterns as JSON

✅ **Validated** - Built-in pattern validation and best practices

## Quick Start

### Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  haptic_composer: ^0.0.2
```

### Basic Usage

```dart
import 'package:haptic_composer/haptic_composer.dart';

// Initialize at app startup
await HapticComposer.initialize();

// Play a preset pattern
await HapticComposer.play(HapticPresets.success);

// Play a custom pattern
await HapticComposer.play(
  HapticPattern(
    events: [
      HapticEvent.impact(intensity: 0.8, duration: 50),
      HapticEvent.pause(100),
      HapticEvent.impact(intensity: 0.5, duration: 30),
    ],
  ),
);
```

## Platform Setup

### Android

Add the vibrate permission to your `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.VIBRATE" />
```

### iOS

No additional configuration needed. The Core Haptics framework is built-in on iOS 13+.

## Usage Examples

### 1. Using Preset Patterns

The library includes 25+ carefully tuned presets for common interactions:

```dart
// Feedback patterns
await HapticComposer.play(HapticPresets.success);
await HapticComposer.play(HapticPresets.error);
await HapticComposer.play(HapticPresets.warning);
await HapticComposer.play(HapticPresets.notification);
await HapticComposer.play(HapticPresets.buttonPress);
await HapticComposer.play(HapticPresets.lightImpact);
await HapticComposer.play(HapticPresets.mediumImpact);
await HapticComposer.play(HapticPresets.heavyImpact);
```

### 2. Building Custom Patterns

Create unique haptic experiences with the pattern builder:

```dart
final pattern = HapticPattern.builder()
  .impact(intensity: 0.8, duration: 50)
  .pause(100)
  .impact(intensity: 0.5, duration: 30)
  .repeat(2)
  .build();

await HapticComposer.play(pattern);
```

### 3. Haptic Buttons

Add haptic feedback directly to buttons:

```dart
HapticButton(
  onPressed: () {
    // Handle button press
  },
  pattern: HapticPresets.buttonPress,
  child: const Text('Press Me'),
)
```

### 4. Interactive Widgets

Wrap any widget to add haptic feedback on interaction:

```dart
TapHaptic(
  pattern: HapticPresets.success,
  child: Card(
    child: Text('Tap me for haptic feedback'),
  ),
)
```

### 5. Scroll Haptics

Add haptic feedback to scrollable content:

```dart
HapticScrollView(
  hapticPattern: HapticPresets.lightImpact,
  child: ListView(
    children: [...],
  ),
)
```

### 6. Pattern Serialization

Save and load patterns as JSON:

```dart
// Save
final json = pattern.toJson();

// Load
final loadedPattern = HapticPattern.fromJson(json);
await HapticComposer.play(loadedPattern);
```

## API Overview

### HapticComposer

Main API for playing haptic patterns.

```dart
// Initialize (call once at app startup)
await HapticComposer.initialize();

// Play a pattern
await HapticComposer.play(HapticPattern pattern);

// Stop current pattern
await HapticComposer.stop();
```

### HapticPattern

Define haptic experiences with events and timing.

```dart
HapticPattern(
  events: [
    HapticEvent.impact(intensity: 0.8, duration: 50),
    HapticEvent.pause(100),
  ],
)
```

### HapticPresets

25+ built-in patterns:
- Impact patterns (light, medium, heavy)
- Feedback patterns (success, error, warning, notification)
- Interaction patterns (button press, selection)
- And many more...

## Validation

The package includes a built-in validator to ensure patterns follow best practices:

```dart
final validation = HapticValidator.validate(pattern);
if (validation.isValid) {
  await HapticComposer.play(pattern);
} else {
  print('Validation errors: ${validation.errors}');
}
```

## Platform Support

| Platform | Support     |
|----------|-----------|
| iOS      | ✅ Core Haptics API (iOS 13+) |
| Android  | ✅ VibrationEffect API (Android 5+) |


## Support

If you find this package helpful, please consider supporting the development:

[![Buy Me A Coffee](https://img.shields.io/badge/☕_Buy%20Me%20A%20Coffee-Support%20My%20Work-yellow?style=for-the-badge&logoColor=black&link=https://buymeacoffee.com/abhijithsabudev)](https://buymeacoffee.com/abhijithsabudev)

Or give it a ⭐ on [GitHub](https://github.com/abhijithsabudev/haptic_composer)!

## License

MIT License - See [LICENSE](LICENSE) file for details.

---

Made with ❤️ for flutter community
