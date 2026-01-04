import '../models/haptic_pattern.dart';
import '../models/haptic_event.dart';

/// Validates haptic patterns for correctness and best practices
///
/// This class provides validation utilities to ensure haptic patterns
/// are properly formatted and follow recommended practices.
class HapticValidator {
  HapticValidator._(); // Private constructor to prevent instantiation

  /// Validates a complete haptic pattern
  ///
  /// Returns a list of validation errors, or an empty list if valid.
  static List<String> validate(HapticPattern pattern) {
    final errors = <String>[];

    if (pattern.isEmpty) {
      errors.add('Pattern contains no events');
    }

    // Validate individual events
    for (int i = 0; i < pattern.events.length; i++) {
      final eventErrors = _validateEvent(pattern.events[i], index: i);
      errors.addAll(eventErrors);
    }

    // Validate total duration
    if (pattern.totalDuration.inMilliseconds > 10000) {
      errors.add('Pattern duration exceeds recommended maximum of 10000ms');
    }

    // Validate repeat count
    if (pattern.repeat != null && pattern.repeat! > 1000) {
      errors.add(
        'Pattern repeat count is very high (${pattern.repeat}), may impact performance',
      );
    }

    return errors;
  }

  /// Validates a single haptic event
  ///
  /// Returns a list of validation errors for the event.
  static List<String> _validateEvent(HapticEvent event, {required int index}) {
    final errors = <String>[];
    final prefix = 'Event $index:';

    // Validate intensity
    if (event.intensity < 0.0 || event.intensity > 1.0) {
      errors.add(
        '$prefix Intensity out of range [0.0, 1.0]: ${event.intensity}',
      );
    }

    // Validate duration
    if (event.duration < 0) {
      errors.add('$prefix Duration is negative: ${event.duration}ms');
    }

    if (event.duration > 5000) {
      errors.add(
        '$prefix Duration exceeds recommended maximum: ${event.duration}ms',
      );
    }

    // Validate sharpness
    if (event.sharpness != null) {
      if (event.sharpness! < 0.0 || event.sharpness! > 1.0) {
        errors.add(
          '$prefix Sharpness out of range [0.0, 1.0]: ${event.sharpness}',
        );
      }
    }

    // Warn about zero-duration impacts
    if (event.type != HapticEventType.pause && event.duration == 0) {
      errors.add('$prefix ${event.type} event has zero duration');
    }

    // Warn about zero-intensity impacts
    if (event.type != HapticEventType.pause && event.intensity == 0.0) {
      errors.add(
        '$prefix ${event.type} event has zero intensity (will be silent)',
      );
    }

    return errors;
  }

  /// Checks if a pattern is valid (has no errors)
  static bool isValid(HapticPattern pattern) {
    return validate(pattern).isEmpty;
  }

  /// Validates and returns a report
  static ValidationReport getReport(HapticPattern pattern) {
    final errors = validate(pattern);
    final warnings = _getWarnings(pattern);

    return ValidationReport(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
      pattern: pattern,
    );
  }

  /// Gets warnings about the pattern (non-critical issues)
  static List<String> _getWarnings(HapticPattern pattern) {
    final warnings = <String>[];

    // Warn about many events
    if (pattern.eventCount > 20) {
      warnings.add(
        'Pattern contains many events (${pattern.eventCount}), consider simplifying',
      );
    }

    // Warn about very long durations
    if (pattern.totalDuration.inSeconds > 5) {
      warnings.add(
        'Pattern duration is very long (${pattern.totalDuration.inSeconds}s), may be overwhelming',
      );
    }

    // Warn about inconsistent intensities
    final intensities = pattern.events
        .where((e) => e.type != HapticEventType.pause)
        .map((e) => e.intensity)
        .toList();

    if (intensities.isNotEmpty) {
      final maxIntensity = intensities.reduce((a, b) => a > b ? a : b);
      final minIntensity = intensities.reduce((a, b) => a < b ? a : b);

      if ((maxIntensity - minIntensity) < 0.1) {
        warnings.add(
          'Pattern has very consistent intensities, could be more dynamic',
        );
      }
    }

    return warnings;
  }

  /// Normalizes a pattern to ensure all values are within valid ranges
  static HapticPattern normalize(HapticPattern pattern) {
    final normalizedEvents = pattern.events.map((event) {
      return HapticEvent(
        type: event.type,
        intensity: event.intensity.clamp(0.0, 1.0),
        duration: event.duration.clamp(0, 5000),
        sharpness: event.sharpness != null
            ? event.sharpness!.clamp(0.0, 1.0)
            : null,
      );
    }).toList();

    return HapticPattern(
      events: normalizedEvents,
      repeat: pattern.repeat,
      delay: pattern.delay,
    );
  }

  /// Gets recommended values for best practices
  static const RecommendedValues recommendations = RecommendedValues();
}

/// Validation report for a haptic pattern
class ValidationReport {
  /// Whether the pattern is valid
  final bool isValid;

  /// List of errors (makes the pattern invalid)
  final List<String> errors;

  /// List of warnings (non-critical issues)
  final List<String> warnings;

  /// The pattern being validated
  final HapticPattern pattern;

  /// Creates a validation report
  const ValidationReport({
    required this.isValid,
    required this.errors,
    required this.warnings,
    required this.pattern,
  });

  /// Gets a human-readable summary
  String getSummary() {
    final buffer = StringBuffer();

    if (isValid && warnings.isEmpty) {
      buffer.writeln('✓ Pattern is valid');
    } else if (isValid) {
      buffer.writeln('✓ Pattern is valid (with ${warnings.length} warning(s))');
    } else {
      buffer.writeln('✗ Pattern is invalid');
    }

    if (errors.isNotEmpty) {
      buffer.writeln('\nErrors:');
      for (final error in errors) {
        buffer.writeln('  - $error');
      }
    }

    if (warnings.isNotEmpty) {
      buffer.writeln('\nWarnings:');
      for (final warning in warnings) {
        buffer.writeln('  - $warning');
      }
    }

    return buffer.toString();
  }

  @override
  String toString() => getSummary();
}

/// Recommended values for haptic patterns
class RecommendedValues {
  /// Recommended minimum intensity for perceptible feedback
  static const double minPerceptibleIntensity = 0.1;

  /// Recommended maximum intensity to avoid discomfort
  static const double maxComfortableIntensity = 0.9;

  /// Recommended minimum duration for perceptible feedback (ms)
  static const int minDuration = 10;

  /// Recommended maximum duration for a single event (ms)
  static const int maxSingleEventDuration = 500;

  /// Recommended maximum total pattern duration (ms)
  static const int maxPatternDuration = 5000;

  /// Recommended minimum pause between events (ms)
  static const int minPauseBetweenEvents = 20;

  const RecommendedValues();
}
