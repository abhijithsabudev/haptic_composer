import '../models/haptic_pattern.dart';
import '../models/haptic_event.dart';
import '../models/haptic_effect.dart';

/// Pre-built haptic patterns for common use cases
///
/// This class provides ready-to-use haptic patterns that can be played
/// directly without creating custom patterns. These patterns are designed
/// to provide consistent feedback across different app experiences.
class HapticPresets {
  HapticPresets._(); // Private constructor to prevent instantiation

  // ============= Feedback Patterns =============

  /// Pattern for successful actions
  ///
  /// Double tap pattern with increasing intensity
  static final HapticPattern success = HapticPattern.builder()
      .impact(intensity: 0.6, duration: 30)
      .pause(80)
      .impact(intensity: 0.8, duration: 40)
      .build();

  /// Pattern for error or failure
  ///
  /// Triple short bursts at high intensity
  static final HapticPattern error = HapticPattern.builder()
      .impact(intensity: 0.9, duration: 20)
      .pause(50)
      .impact(intensity: 0.9, duration: 20)
      .pause(50)
      .impact(intensity: 0.9, duration: 20)
      .build();

  /// Pattern for warnings
  ///
  /// Single strong pulse
  static final HapticPattern warning = HapticPattern.builder()
      .impact(intensity: 0.9, duration: 60)
      .build();

  /// Pattern for notifications
  ///
  /// Ascending intensity pattern
  static final HapticPattern notification = HapticPattern.builder()
      .impact(intensity: 0.3, duration: 40)
      .pause(60)
      .impact(intensity: 0.6, duration: 40)
      .pause(60)
      .impact(intensity: 0.9, duration: 40)
      .build();

  // ============= Interaction Patterns =============

  /// Pattern for button presses
  ///
  /// Quick, sharp impact
  static final HapticPattern buttonPress = HapticPattern.builder()
      .impact(intensity: 0.7, duration: 40, sharpness: 0.9)
      .build();

  /// Pattern for toggle/switch actions
  ///
  /// Soft double tap
  static final HapticPattern toggle = HapticPattern.builder()
      .impact(intensity: 0.5, duration: 25)
      .pause(40)
      .impact(intensity: 0.5, duration: 25)
      .build();

  /// Pattern for long press detection
  ///
  /// Sustained vibration building in intensity - signals press is recognized
  static final HapticPattern longPress = HapticPattern.builder()
      .continuous(intensity: 0.2, duration: 150)
      .continuous(intensity: 0.5, duration: 150)
      .continuous(intensity: 0.8, duration: 150)
      .continuous(intensity: 1.0, duration: 100)
      .build();

  /// Pattern for long tap release confirmation
  ///
  /// Haptic confirmation when long tap action completes
  static final HapticPattern longTap = HapticPattern.builder()
      .impact(intensity: 0.7, duration: 70, sharpness: 0.8)
      .pause(60)
      .impact(intensity: 0.5, duration: 50, sharpness: 0.7)
      .build();

  /// Pattern for swipe/drag interactions
  ///
  /// Smooth continuous effect
  static final HapticPattern swipe = HapticPattern.builder()
      .continuous(intensity: 0.5, duration: 150)
      .build();

  /// Pattern for successful selection/confirmation
  ///
  /// Quick double tap with decreasing intensity
  static final HapticPattern selection = HapticPattern.builder()
      .impact(intensity: 0.8, duration: 35)
      .pause(50)
      .impact(intensity: 0.5, duration: 35)
      .build();

  // ============= Advanced Patterns =============

  /// Pattern mimicking a heartbeat
  ///
  /// Realistic dual-beat rhythm like actual heartbeat (lub-dub)
  static final HapticPattern heartbeat = HapticPattern.builder()
      .impact(intensity: 0.8, duration: 60, sharpness: 0.7)
      .pause(40)
      .impact(intensity: 0.6, duration: 50, sharpness: 0.6)
      .pause(900)
      .build();

  /// Pattern for a pulse/breathing effect
  ///
  /// Smooth wave-like effect mimicking breathing
  static final HapticPattern pulse = HapticPattern.builder()
      .continuous(intensity: 0.2, duration: 100)
      .continuous(intensity: 0.5, duration: 150)
      .continuous(intensity: 0.8, duration: 100)
      .continuous(intensity: 0.5, duration: 150)
      .continuous(intensity: 0.2, duration: 100)
      .build();

  /// Pattern mimicking a drumroll
  ///
  /// Fast, accelerating sequence of impacts
  static final HapticPattern drumroll = HapticPattern.builder()
      .impact(intensity: 0.4, duration: 10)
      .pause(10)
      .impact(intensity: 0.4, duration: 10)
      .pause(10)
      .impact(intensity: 0.5, duration: 12)
      .pause(10)
      .impact(intensity: 0.5, duration: 12)
      .pause(8)
      .impact(intensity: 0.6, duration: 15)
      .pause(8)
      .impact(intensity: 0.7, duration: 15)
      .pause(6)
      .impact(intensity: 0.8, duration: 18)
      .pause(6)
      .impact(intensity: 0.9, duration: 20)
      .build();

  /// Pattern like ripples in water
  ///
  /// Multiple waves with realistic decay
  static final HapticPattern ripple = HapticPattern.builder()
      .impact(intensity: 0.9, duration: 50, sharpness: 0.8)
      .pause(120)
      .impact(intensity: 0.6, duration: 40, sharpness: 0.7)
      .pause(150)
      .impact(intensity: 0.3, duration: 30, sharpness: 0.6)
      .pause(200)
      .impact(intensity: 0.15, duration: 20, sharpness: 0.5)
      .build();

  /// Pattern for capturing attention
  ///
  /// Strong opening impact with follow-up pulses
  static final HapticPattern attention = HapticPattern.builder()
      .impact(intensity: 1.0, duration: 80, sharpness: 0.9)
      .pause(200)
      .impact(intensity: 0.5, duration: 40, sharpness: 0.7)
      .pause(150)
      .impact(intensity: 0.5, duration: 40, sharpness: 0.7)
      .build();

  /// Pattern for scrolling/momentum
  ///
  /// Gentle continuous vibration
  static final HapticPattern scroll = HapticPattern.builder()
      .continuous(intensity: 0.2, duration: 150)
      .continuous(intensity: 0.3, duration: 100)
      .build();

  /// Pattern for bounce/spring effect
  ///
  /// Realistic bouncing with decreasing intensity and timing
  static final HapticPattern bounce = HapticPattern.builder()
      .impact(intensity: 0.9, duration: 40, sharpness: 0.8)
      .pause(40)
      .impact(intensity: 0.6, duration: 35, sharpness: 0.7)
      .pause(50)
      .impact(intensity: 0.4, duration: 30, sharpness: 0.6)
      .pause(70)
      .impact(intensity: 0.2, duration: 25, sharpness: 0.5)
      .build();

  // ============= Utility Patterns =============

  /// Subtle single tap for gentle feedback
  static final HapticPattern tap = HapticPattern.builder()
      .impact(intensity: 0.6, duration: 30, sharpness: 0.8)
      .build();

  /// Very subtle feedback
  static final HapticPattern light = HapticPattern.builder()
      .impact(intensity: HapticEffect.intensityLight, duration: 25)
      .build();

  /// Standard medium feedback
  static final HapticPattern medium = HapticPattern.builder()
      .impact(
        intensity: HapticEffect.intensityMedium,
        duration: 60,
        sharpness: 0.7,
      )
      .build();

  /// Strong, prominent feedback
  static final HapticPattern strong = HapticPattern.builder()
      .impact(
        intensity: HapticEffect.intensityStrong,
        duration: 80,
        sharpness: 0.9,
      )
      .build();

  /// Very subtle double tap
  static final HapticPattern doubleTap = HapticPattern.builder()
      .impact(intensity: 0.5, duration: 20, sharpness: 0.7)
      .pause(40)
      .impact(intensity: 0.5, duration: 20, sharpness: 0.7)
      .build();

  /// Pattern for item deletion/removal
  static final HapticPattern delete = HapticPattern.builder()
      .impact(intensity: 0.8, duration: 40)
      .pause(40)
      .impact(intensity: 0.6, duration: 30)
      .pause(40)
      .impact(intensity: 0.4, duration: 20)
      .build();

  /// Pattern for positive/affirmative response
  static final HapticPattern positive = HapticPattern.builder()
      .impact(intensity: 0.7, duration: 25)
      .pause(35)
      .impact(intensity: 0.8, duration: 35)
      .build();

  /// Pattern for negative/dismissive response
  static final HapticPattern negative = HapticPattern.builder()
      .impact(intensity: 0.7, duration: 20)
      .pause(30)
      .impact(intensity: 0.7, duration: 20)
      .build();

  /// Silent pattern (minimal pause, no actual haptic feedback)
  static final HapticPattern silent = HapticPattern(
    events: [
      HapticEvent.pause(1), // Minimal pause instead of empty
    ],
  );

  /// Get all available presets as a map
  static final Map<String, HapticPattern> all = {
    // Feedback
    'success': success,
    'error': error,
    'warning': warning,
    'notification': notification,

    // Interaction
    'buttonPress': buttonPress,
    'toggle': toggle,
    'longPress': longPress,
    'longTap': longTap,
    'swipe': swipe,
    'selection': selection,

    // Advanced
    'heartbeat': heartbeat,
    'pulse': pulse,
    'drumroll': drumroll,
    'ripple': ripple,
    'attention': attention,
    'scroll': scroll,
    'bounce': bounce,

    // Utility
    'tap': tap,
    'light': light,
    'medium': medium,
    'strong': strong,
    'doubleTap': doubleTap,
    'delete': delete,
    'positive': positive,
    'negative': negative,
    'silent': silent,
  };
}
