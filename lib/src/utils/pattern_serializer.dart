import 'dart:convert';
import '../models/haptic_pattern.dart';

/// Handles serialization and deserialization of haptic patterns
///
/// This class provides utilities for converting haptic patterns
/// to and from JSON format for storage and transmission.
class PatternSerializer {
  PatternSerializer._(); // Private constructor to prevent instantiation

  /// Converts a haptic pattern to a JSON string
  ///
  /// The resulting JSON can be saved to storage or transmitted over the network.
  static String toJsonString(HapticPattern pattern) {
    return jsonEncode(pattern.toJson());
  }

  /// Converts a JSON string to a haptic pattern
  ///
  /// Throws FormatException if the JSON is invalid.
  static HapticPattern fromJsonString(String json) {
    try {
      final Map<String, dynamic> data = jsonDecode(json);
      return HapticPattern.fromJson(data);
    } catch (e) {
      throw FormatException('Invalid haptic pattern JSON: $e');
    }
  }

  /// Converts a haptic pattern to a JSON map
  static Map<String, dynamic> toJson(HapticPattern pattern) {
    return pattern.toJson();
  }

  /// Converts a JSON map to a haptic pattern
  static HapticPattern fromJson(Map<String, dynamic> json) {
    return HapticPattern.fromJson(json);
  }

  /// Exports a pattern with metadata
  ///
  /// Includes version, creation date, and pattern name for better tracking.
  static Map<String, dynamic> exportWithMetadata(
    HapticPattern pattern, {
    required String name,
    String? description,
  }) {
    return {
      'version': '1.0',
      'createdAt': DateTime.now().toIso8601String(),
      'name': name,
      if (description != null) 'description': description,
      'pattern': pattern.toJson(),
    };
  }

  /// Imports a pattern from metadata
  static HapticPattern importFromMetadata(Map<String, dynamic> data) {
    if (!data.containsKey('pattern')) {
      throw FormatException('Missing pattern data in metadata');
    }
    return HapticPattern.fromJson(data['pattern']);
  }

  /// Pretty prints a pattern for debugging
  static String prettyPrint(HapticPattern pattern) {
    final buffer = StringBuffer();
    buffer.writeln('HapticPattern {');
    buffer.writeln('  Duration: ${pattern.totalDuration.inMilliseconds}ms');
    buffer.writeln('  Events: ${pattern.eventCount}');
    if (pattern.repeat != null) {
      buffer.writeln('  Repeat: ${pattern.repeat}x');
    }
    if (pattern.delay != null) {
      buffer.writeln('  Delay: ${pattern.delay!.inMilliseconds}ms');
    }
    buffer.writeln('  Events:');
    for (var event in pattern.events) {
      buffer.writeln('    $event');
    }
    buffer.writeln('}');
    return buffer.toString();
  }
}
