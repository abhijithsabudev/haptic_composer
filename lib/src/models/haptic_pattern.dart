import 'package:flutter/foundation.dart';
import 'haptic_event.dart';

/// Represents a sequence of haptic events that can be played
///
/// A haptic pattern is composed of one or more haptic events that define
/// a complete haptic experience. Patterns can be repeated and optionally
/// delayed. Includes comprehensive validation to ensure patterns are valid.
class HapticPattern {
  /// The list of haptic events in this pattern
  final List<HapticEvent> events;

  /// Number of times to repeat the pattern
  ///
  /// null means infinite repetition
  final int? repeat;

  /// Initial delay before playing the pattern (milliseconds)
  final Duration? delay;

  /// Maximum allowed pattern duration (30 seconds)
  static const Duration maxPatternDuration = Duration(seconds: 30);

  /// Creates a haptic pattern with validation
  ///
  /// Throws [ArgumentError] if pattern is invalid.
  HapticPattern({required this.events, this.repeat, this.delay}) {
    _validate();
  }

  /// Validates the pattern
  void _validate() {
    if (events.isEmpty) {
      throw ArgumentError('Pattern must contain at least one event');
    }

    if (repeat != null && repeat! <= 0) {
      throw ArgumentError('Repeat count must be positive, got $repeat');
    }

    if (delay != null && delay!.isNegative) {
      throw ArgumentError(
        'Delay cannot be negative, got ${delay!.inMilliseconds}ms',
      );
    }

    // Check total pattern duration
    final totalMs = totalDuration.inMilliseconds;
    if (totalMs > maxPatternDuration.inMilliseconds && repeat != null) {
      if (kDebugMode) {
        print(
          '[HapticPattern] Warning: Pattern duration (${totalMs}ms) '
          'may exceed recommended maximum (${maxPatternDuration.inMilliseconds}ms) with repeats',
        );
      }
    }

    if (kDebugMode) {
      print(
        '[HapticPattern] Created pattern: '
        'events=${events.length}, '
        'duration=${totalDuration.inMilliseconds}ms, '
        'repeat=${repeat ?? "infinite"}, '
        'delay=${delay?.inMilliseconds ?? 0}ms',
      );
    }
  }

  /// Calculates the total duration of the pattern (for one iteration)
  Duration get totalDuration {
    if (events.isEmpty) return Duration.zero;
    final totalMs = events.fold<int>(0, (sum, event) => sum + event.duration);
    return Duration(milliseconds: totalMs);
  }

  /// Calculates the total duration including all repetitions
  Duration get totalDurationWithRepeats {
    if (repeat == null) return Duration(milliseconds: -1); // infinite
    final duration = totalDuration.inMilliseconds * (repeat ?? 1);
    return Duration(milliseconds: duration);
  }

  /// Number of events in this pattern
  int get eventCount => events.length;

  /// Checks if this pattern has any events
  bool get isEmpty => events.isEmpty;

  /// Checks if this pattern repeats infinitely
  bool get isInfinite => repeat == null;

  /// Creates a new pattern with modified properties
  ///
  /// Throws [ArgumentError] if resulting pattern would be invalid.
  HapticPattern copyWith({
    List<HapticEvent>? events,
    int? repeat,
    Duration? delay,
  }) {
    return HapticPattern(
      events: events ?? this.events,
      repeat: repeat ?? this.repeat,
      delay: delay ?? this.delay,
    );
  }

  /// Converts this pattern to a JSON representation
  Map<String, dynamic> toJson() {
    return {
      'events': events.map((e) => e.toJson()).toList(),
      if (repeat != null) 'repeat': repeat,
      if (delay != null) 'delay': delay!.inMilliseconds,
    };
  }

  /// Creates a haptic pattern from a JSON representation
  ///
  /// Throws [FormatException] if JSON is invalid.
  factory HapticPattern.fromJson(Map<String, dynamic> json) {
    try {
      final eventsList =
          (json['events'] as List?)
              ?.map((e) => HapticEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];

      if (eventsList.isEmpty) {
        throw FormatException('Pattern must contain at least one event');
      }

      return HapticPattern(
        events: eventsList,
        repeat: json['repeat'] as int?,
        delay: json['delay'] != null
            ? Duration(milliseconds: json['delay'] as int)
            : null,
      );
    } catch (e) {
      if (kDebugMode) {
        print('[HapticPattern] Error parsing JSON: $e');
      }
      rethrow;
    }
  }

  /// Creates a pattern builder for fluent pattern construction
  static HapticPatternBuilder builder() {
    return HapticPatternBuilder();
  }

  @override
  String toString() =>
      'HapticPattern('
      'events: ${events.length}, '
      'duration: ${totalDuration.inMilliseconds}ms'
      '${repeat != null ? ', repeat: $repeat' : ''}'
      '${delay != null ? ', delay: ${delay!.inMilliseconds}ms' : ''}'
      ')';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HapticPattern &&
          runtimeType == other.runtimeType &&
          events == other.events &&
          repeat == other.repeat &&
          delay == other.delay;

  @override
  int get hashCode => events.hashCode ^ repeat.hashCode ^ delay.hashCode;
}

/// Builder class for fluent haptic pattern construction
///
/// Use this to build haptic patterns using a fluent, chainable API.
/// Validates patterns during construction and prevents invalid states.
/// Example:
/// ```dart
/// final pattern = HapticPattern.builder()
///   .impact(intensity: 0.8, duration: 50)
///   .pause(100)
///   .impact(intensity: 0.5, duration: 30)
///   .repeat(2)
///   .build();
/// ```
class HapticPatternBuilder {
  final List<HapticEvent> _events = [];
  int? _repeat;
  Duration? _delay;

  /// Adds an impact event to the pattern
  ///
  /// Throws [ArgumentError] if parameters are invalid.
  HapticPatternBuilder impact({
    required double intensity,
    required int duration,
    double? sharpness,
  }) {
    _events.add(
      HapticEvent.impact(
        intensity: intensity,
        duration: duration,
        sharpness: sharpness,
      ),
    );
    return this;
  }

  /// Adds a continuous event to the pattern
  ///
  /// Throws [ArgumentError] if parameters are invalid.
  HapticPatternBuilder continuous({
    required double intensity,
    required int duration,
    double? sharpness,
  }) {
    _events.add(
      HapticEvent.continuous(
        intensity: intensity,
        duration: duration,
        sharpness: sharpness,
      ),
    );
    return this;
  }

  /// Adds a pause to the pattern
  ///
  /// Throws [ArgumentError] if duration is invalid.
  HapticPatternBuilder pause(int duration) {
    _events.add(HapticEvent.pause(duration));
    return this;
  }

  /// Adds a custom event to the pattern
  HapticPatternBuilder addEvent(HapticEvent event) {
    _events.add(event);
    return this;
  }

  /// Adds multiple events to the pattern
  HapticPatternBuilder addEvents(List<HapticEvent> events) {
    if (events.isEmpty) {
      throw ArgumentError('Cannot add empty event list');
    }
    _events.addAll(events);
    return this;
  }

  /// Sets the repeat count for the pattern
  ///
  /// Pass null for infinite repetition.
  /// Throws [ArgumentError] if count is invalid.
  HapticPatternBuilder repeat(int? count) {
    if (count != null && count <= 0) {
      throw ArgumentError('Repeat count must be positive, got $count');
    }
    _repeat = count;
    return this;
  }

  /// Sets the initial delay before the pattern plays
  ///
  /// Throws [ArgumentError] if delay is negative.
  HapticPatternBuilder delay(Duration duration) {
    if (duration.isNegative) {
      throw ArgumentError(
        'Delay cannot be negative, got ${duration.inMilliseconds}ms',
      );
    }
    _delay = duration;
    return this;
  }

  /// Clears all events from the builder
  HapticPatternBuilder clear() {
    _events.clear();
    _repeat = null;
    _delay = null;
    return this;
  }

  /// Gets the current number of events in the builder
  int get eventCount => _events.length;

  /// Checks if the builder has any events
  bool get isEmpty => _events.isEmpty;

  /// Builds and returns the final HapticPattern
  ///
  /// Throws [StateError] if no events have been added.
  HapticPattern build() {
    if (_events.isEmpty) {
      throw StateError(
        'Cannot build pattern with no events. Add at least one event.',
      );
    }

    if (kDebugMode) {
      print(
        '[HapticPatternBuilder] Building pattern with '
        '${_events.length} events, repeat=${_repeat ?? "infinite"}',
      );
    }

    return HapticPattern(
      events: List.unmodifiable(_events),
      repeat: _repeat,
      delay: _delay,
    );
  }
}
