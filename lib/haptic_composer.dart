library haptic_composer;

import 'src/engine/haptic_engine.dart';
import 'src/models/haptic_pattern.dart';

// Models
export 'src/models/haptic_pattern.dart';
export 'src/models/haptic_event.dart';
export 'src/models/haptic_effect.dart';

// Engine
export 'src/engine/haptic_engine.dart';
export 'src/engine/platform_adapter.dart';

// Presets
export 'src/presets/haptic_presets.dart';

// Utils
export 'src/utils/pattern_serializer.dart';
export 'src/utils/haptic_validator.dart';

// Widgets
export 'widgets/haptic_button.dart';
export 'widgets/haptic_feedback_wrapper.dart';
export 'widgets/haptic_scroll_view.dart';

// Composer
export 'src/composer/visual_composer_widget.dart';

/// Main entry point for the haptic composer package
///
/// This class provides convenient static methods for common haptic operations.
class HapticComposer {
  static final HapticComposer _instance = HapticComposer._internal();
  final _engine = HapticEngine();

  /// Private constructor for singleton pattern
  HapticComposer._internal();

  /// Gets the singleton instance
  factory HapticComposer() {
    return _instance;
  }

  /// Plays a haptic pattern
  ///
  /// Example:
  /// ```dart
  /// // Play a preset pattern
  /// await HapticComposer.play(HapticPresets.success);
  ///
  /// // Play a custom pattern
  /// await HapticComposer.play(
  ///   HapticPattern(events: [
  ///     HapticEvent.impact(intensity: 0.8, duration: 50),
  ///     HapticEvent.pause(100),
  ///     HapticEvent.impact(intensity: 0.5, duration: 30),
  ///   ]),
  /// );
  /// ```
  static Future<void> play(
    HapticPattern pattern, {
    OnHapticComplete? onComplete,
    OnHapticError? onError,
  }) {
    return _instance._engine.play(
      pattern,
      onComplete: onComplete,
      onError: onError,
    );
  }

  /// Stops the currently playing pattern
  static Future<void> stop() {
    return _instance._engine.stop();
  }

  /// Initializes the haptic engine
  ///
  /// Should be called once at app startup.
  static Future<bool> initialize() {
    return _instance._engine.initialize();
  }

  /// Disposes the haptic engine
  ///
  /// Should be called when the app is shutting down.
  static Future<void> dispose() {
    return _instance._engine.dispose();
  }

  /// Checks if a pattern is currently playing
  static bool get isPlaying => _instance._engine.isPlaying;

  /// Checks if the device supports haptic feedback
  static Future<bool> isSupported() {
    return _instance._engine.isHapticFeedbackEnabled();
  }

  /// Resets the haptic engine to initial state
  static Future<void> reset() {
    return _instance._engine.reset();
  }

  /// Sets global callbacks for haptic playback events
  static void setCallbacks({
    OnHapticComplete? onComplete,
    OnHapticError? onError,
  }) {
    _instance._engine.setCallbacks(onComplete: onComplete, onError: onError);
  }

  /// Gets the initialization status
  static bool get isInitialized => _instance._engine.isInitialized;

  /// Gets the disposal status
  static bool get isDisposed => _instance._engine.isDisposed;

  /// Gets the underlying haptic engine for advanced use cases
  static HapticEngine get engine => _instance._engine;
}
