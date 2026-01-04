import 'package:flutter_test/flutter_test.dart';
import 'package:haptic_composer/haptic_composer.dart';

void main() {
  group('HapticEvent', () {
    test('creates impact event correctly', () {
      final event = HapticEvent.impact(intensity: 0.8, duration: 50);
      expect(event.type, HapticEventType.impact);
      expect(event.intensity, 0.8);
      expect(event.duration, 50);
    });

    test('creates pause event correctly', () {
      final event = HapticEvent.pause(100);
      expect(event.type, HapticEventType.pause);
      expect(event.duration, 100);
    });

    test('validates intensity range', () {
      expect(
        () => HapticEvent.impact(intensity: 1.5, duration: 50),
        throwsArgumentError,
      );
      expect(
        () => HapticEvent.impact(intensity: -0.5, duration: 50),
        throwsArgumentError,
      );
    });

    test('converts to and from JSON', () {
      final event = HapticEvent.impact(intensity: 0.7, duration: 40);
      final json = event.toJson();
      final restored = HapticEvent.fromJson(json);

      expect(restored.type, event.type);
      expect(restored.intensity, event.intensity);
      expect(restored.duration, event.duration);
    });
  });

  group('HapticPattern', () {
    test('calculates total duration correctly', () {
      final pattern = HapticPattern(
        events: [
          HapticEvent.impact(intensity: 0.8, duration: 50),
          HapticEvent.pause(100),
          HapticEvent.impact(intensity: 0.5, duration: 30),
        ],
      );

      expect(pattern.totalDuration.inMilliseconds, 180);
    });

    test('builder pattern works correctly', () {
      final pattern = HapticPattern.builder()
          .impact(intensity: 0.8, duration: 50)
          .pause(100)
          .impact(intensity: 0.5, duration: 30)
          .build();

      expect(pattern.eventCount, 3);
      expect(pattern.totalDuration.inMilliseconds, 180);
    });

    test('converts to and from JSON', () {
      final pattern = HapticPattern(
        events: [
          HapticEvent.impact(intensity: 0.8, duration: 50),
          HapticEvent.pause(100),
        ],
        repeat: 2,
      );

      final json = pattern.toJson();
      final restored = HapticPattern.fromJson(json);

      expect(restored.eventCount, pattern.eventCount);
      expect(restored.totalDuration, pattern.totalDuration);
      expect(restored.repeat, pattern.repeat);
    });

    test('empty pattern throws error on builder', () {
      expect(() => HapticPatternBuilder().build(), throwsStateError);
    });
  });

  group('HapticPresets', () {
    test('success preset exists and has events', () {
      final pattern = HapticPresets.success;
      expect(pattern.events.isNotEmpty, true);
      expect(pattern.eventCount, greaterThan(0));
    });

    test('all presets are valid', () {
      for (final preset in HapticPresets.all.values) {
        expect(preset.events.isNotEmpty, true);
      }
    });

    test('presets have reasonable durations', () {
      for (final preset in HapticPresets.all.values) {
        expect(preset.totalDuration.inMilliseconds, lessThanOrEqualTo(5000));
      }
    });
  });

  group('HapticValidator', () {
    test('validates correct pattern', () {
      final pattern = HapticPattern(
        events: [HapticEvent.impact(intensity: 0.8, duration: 50)],
      );

      expect(HapticValidator.isValid(pattern), true);
      expect(HapticValidator.validate(pattern).isEmpty, true);
    });

    test('detects empty pattern', () {
      // Empty pattern creation now throws ArgumentError during construction
      expect(() => HapticPattern(events: []), throwsArgumentError);
    });

    test('detects invalid intensity', () {
      // Invalid intensity is caught during construction now
      expect(
        () => HapticEvent(
          type: HapticEventType.impact,
          intensity: 1.5, // Invalid
          duration: 50,
        ),
        throwsAssertionError,
      );
    });

    test('normalizes pattern values', () {
      // Create a valid pattern first, then normalize
      final pattern = HapticPattern(
        events: [HapticEvent.impact(intensity: 0.8, duration: 50)],
      );

      final normalized = HapticValidator.normalize(pattern);
      expect(normalized.events.first.intensity, 0.8);
      expect(normalized.events.first.duration, 50);
    });
  });

  group('PatternSerializer', () {
    test('serializes and deserializes pattern', () {
      final original = HapticPattern(
        events: [
          HapticEvent.impact(intensity: 0.8, duration: 50),
          HapticEvent.pause(100),
        ],
      );

      final json = PatternSerializer.toJsonString(original);
      final restored = PatternSerializer.fromJsonString(json);

      expect(restored.eventCount, original.eventCount);
      expect(restored.totalDuration, original.totalDuration);
    });

    test('export with metadata preserves pattern data', () {
      final pattern = HapticPattern(
        events: [HapticEvent.impact(intensity: 0.8, duration: 50)],
      );

      final exported = PatternSerializer.exportWithMetadata(
        pattern,
        name: 'Test Pattern',
      );

      expect(exported['name'], 'Test Pattern');
      expect(exported['pattern'], isNotNull);

      final imported = PatternSerializer.importFromMetadata(exported);
      expect(imported.eventCount, pattern.eventCount);
    });

    test('invalid JSON throws FormatException', () {
      expect(
        () => PatternSerializer.fromJsonString('invalid json'),
        throwsFormatException,
      );
    });
  });

  group('HapticEffect', () {
    test('intensity constants are valid', () {
      expect(HapticEffect.intensityLight, 0.1);
      expect(HapticEffect.intensityMedium, 0.5);
      expect(HapticEffect.intensityStrong, 0.8);
      expect(HapticEffect.intensityMax, 1.0);
    });

    test('duration constants are positive', () {
      expect(HapticEffect.durationShort, greaterThan(0));
      expect(HapticEffect.durationMedium, greaterThan(0));
      expect(HapticEffect.durationLong, greaterThan(0));
    });
  });
}
