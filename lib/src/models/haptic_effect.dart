/// Represents predefined haptic effect parameters
///
/// This class provides constants for common haptic effect intensities
/// and durations that can be used across the package.
class HapticEffect {
  // Intensity levels
  /// Very subtle vibration (10% intensity)
  static const double intensityLight = 0.1;

  /// Medium vibration (50% intensity)
  static const double intensityMedium = 0.5;

  /// Strong vibration (80% intensity)
  static const double intensityStrong = 0.8;

  /// Maximum vibration (100% intensity)
  static const double intensityMax = 1.0;

  // Duration values (in milliseconds)
  /// Very short duration (20ms)
  static const int durationShort = 20;

  /// Medium duration (50ms)
  static const int durationMedium = 50;

  /// Long duration (100ms)
  static const int durationLong = 100;

  // Sharpness levels (iOS only)
  /// Soft/dull sharpness (0% sharpness)
  static const double sharpnessLow = 0.0;

  /// Medium sharpness (50% sharpness)
  static const double sharpnessMedium = 0.5;

  /// High/crisp sharpness (100% sharpness)
  static const double sharpnessHigh = 1.0;

  HapticEffect._(); // Private constructor to prevent instantiation
}
