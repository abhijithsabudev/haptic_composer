import 'package:flutter/foundation.dart';

/// Represents a single haptic event within a pattern
///
/// A haptic event defines what type of vibration occurs, its intensity,
/// duration, and optional sharpness (iOS only). Includes comprehensive
/// validation to ensure parameters are within valid ranges.
class HapticEvent {
  /// The type of haptic event
  final HapticEventType type;

  /// Intensity of the haptic effect (0.0 to 1.0)
  ///
  /// 0.0 = no vibration
  /// 1.0 = maximum vibration
  final double intensity;

  /// Duration of the haptic effect in milliseconds (minimum 1ms)
  final int duration;

  /// Sharpness of the haptic effect (iOS only, 0.0 to 1.0)
  ///
  /// 0.0 = very soft/dull
  /// 1.0 = very sharp/crisp
  /// Only applicable for impact and continuous events
  final double? sharpness;

  /// Minimum valid duration in milliseconds
  static const int minDuration = 1;

  /// Maximum valid duration in milliseconds (30 seconds)
  static const int maxDuration = 30000;

  /// Creates a haptic event with comprehensive validation
  ///
  /// Throws [ArgumentError] if parameters are invalid.
  const HapticEvent({
    required this.type,
    required this.intensity,
    required this.duration,
    this.sharpness,
  }) : assert(
         intensity >= 0.0 && intensity <= 1.0,
         'Intensity must be between 0.0 and 1.0',
       ),
       assert(
         duration >= minDuration && duration <= maxDuration,
         'Duration must be between $minDuration and $maxDuration ms',
       ),
       assert(
         sharpness == null || (sharpness >= 0.0 && sharpness <= 1.0),
         'Sharpness must be between 0.0 and 1.0',
       );

  /// Creates an impact (transient) haptic event
  ///
  /// Impact events are short, sudden vibrations useful for button presses
  /// and taps.
  ///
  /// Throws [ArgumentError] if parameters are out of valid ranges.
  factory HapticEvent.impact({
    required double intensity,
    required int duration,
    double? sharpness,
  }) {
    _validateParameters(
      intensity: intensity,
      duration: duration,
      sharpness: sharpness,
      type: HapticEventType.impact,
    );

    return HapticEvent(
      type: HapticEventType.impact,
      intensity: intensity,
      duration: duration,
      sharpness: sharpness,
    );
  }

  /// Creates a continuous haptic event
  ///
  /// Continuous events are sustained vibrations that last for the specified
  /// duration.
  ///
  /// Throws [ArgumentError] if parameters are out of valid ranges.
  factory HapticEvent.continuous({
    required double intensity,
    required int duration,
    double? sharpness,
  }) {
    _validateParameters(
      intensity: intensity,
      duration: duration,
      sharpness: sharpness,
      type: HapticEventType.continuous,
    );

    return HapticEvent(
      type: HapticEventType.continuous,
      intensity: intensity,
      duration: duration,
      sharpness: sharpness,
    );
  }

  /// Creates a pause (silence) in the pattern
  ///
  /// This is useful for creating gaps between haptic events.
  ///
  /// Throws [ArgumentError] if duration is invalid.
  factory HapticEvent.pause(int duration) {
    if (duration < minDuration || duration > maxDuration) {
      throw ArgumentError(
        'Pause duration must be between $minDuration and $maxDuration ms',
      );
    }

    return HapticEvent(
      type: HapticEventType.pause,
      intensity: 0.0,
      duration: duration,
    );
  }

  /// Validates event parameters
  static void _validateParameters({
    required double intensity,
    required int duration,
    double? sharpness,
    required HapticEventType type,
  }) {
    if (intensity < 0.0 || intensity > 1.0) {
      throw ArgumentError(
        'Intensity must be between 0.0 and 1.0, got $intensity',
      );
    }

    if (duration < minDuration || duration > maxDuration) {
      throw ArgumentError(
        'Duration must be between $minDuration and $maxDuration ms, got $duration',
      );
    }

    if (sharpness != null && (sharpness < 0.0 || sharpness > 1.0)) {
      throw ArgumentError(
        'Sharpness must be between 0.0 and 1.0, got $sharpness',
      );
    }

    if (kDebugMode) {
      print(
        '[HapticEvent] Creating $type event: '
        'intensity=$intensity, duration=${duration}ms, '
        'sharpness=${sharpness ?? "null"}',
      );
    }
  }

  /// Converts this event to a JSON representation
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last,
      'intensity': intensity,
      'duration': duration,
      if (sharpness != null) 'sharpness': sharpness,
    };
  }

  /// Creates a haptic event from a JSON representation
  ///
  /// Throws [FormatException] if JSON is invalid.
  factory HapticEvent.fromJson(Map<String, dynamic> json) {
    try {
      final typeStr = json['type'] as String?;
      if (typeStr == null) {
        throw FormatException('Missing required field: type');
      }

      final type = HapticEventType.values.firstWhere(
        (e) => e.toString().endsWith('.$typeStr'),
        orElse: () => throw FormatException('Invalid event type: $typeStr'),
      );

      final intensity = (json['intensity'] as num?)?.toDouble();
      if (intensity == null) {
        throw FormatException('Missing required field: intensity');
      }

      final duration = json['duration'] as int?;
      if (duration == null) {
        throw FormatException('Missing required field: duration');
      }

      final sharpness = json['sharpness'] != null
          ? (json['sharpness'] as num).toDouble()
          : null;

      return HapticEvent(
        type: type,
        intensity: intensity,
        duration: duration,
        sharpness: sharpness,
      );
    } catch (e) {
      if (kDebugMode) {
        print('[HapticEvent] Error parsing JSON: $e');
      }
      rethrow;
    }
  }

  /// Creates a copy of this event with optional field overrides
  HapticEvent copyWith({
    HapticEventType? type,
    double? intensity,
    int? duration,
    double? sharpness,
  }) {
    return HapticEvent(
      type: type ?? this.type,
      intensity: intensity ?? this.intensity,
      duration: duration ?? this.duration,
      sharpness: sharpness ?? this.sharpness,
    );
  }

  @override
  String toString() =>
      'HapticEvent('
      'type: $type, '
      'intensity: $intensity, '
      'duration: ${duration}ms'
      '${sharpness != null ? ', sharpness: $sharpness' : ''}'
      ')';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HapticEvent &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          intensity == other.intensity &&
          duration == other.duration &&
          sharpness == other.sharpness;

  @override
  int get hashCode =>
      type.hashCode ^
      intensity.hashCode ^
      duration.hashCode ^
      sharpness.hashCode;
}

/// Enumeration of haptic event types
enum HapticEventType {
  /// Short, transient vibration (e.g., button press)
  impact,

  /// Sustained vibration for a duration
  continuous,

  /// Silence/pause in the pattern
  pause,
}
