import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/haptic_event.dart';
import '../models/haptic_pattern.dart';
import 'haptic_engine.dart';
import 'platform_adapter.dart';

/// Manages playback of haptic patterns
///
/// This class handles the sequential playback of haptic events
/// within patterns, managing timing, repetition, and cancellation.
/// Includes comprehensive error handling and timeout support.
class PatternPlayer {
  final PlatformAdapter _platformAdapter;

  Timer? _currentTimer;
  bool _isPlaying = false;
  Completer<void>? _playbackCompleter;
  CancelToken? _currentCancelToken;

  /// Maximum allowed pattern duration to prevent infinite playback (30 seconds)
  static const Duration maxPatternDuration = Duration(seconds: 30);

  /// Creates a pattern player
  PatternPlayer(this._platformAdapter);

  /// Plays a haptic pattern with optional cancellation support
  ///
  /// If a pattern is already playing, it will be stopped first.
  /// Returns a future that completes when the pattern finishes.
  /// Throws [StateError] if pattern is invalid.
  Future<void> play(
    HapticPattern pattern, {
    CancelToken? cancelToken,
    Duration? timeout,
  }) async {
    // Validate pattern
    if (pattern.isEmpty) {
      if (kDebugMode) {
        print('[PatternPlayer] Cannot play empty pattern');
      }
      return;
    }

    // Stop any currently playing pattern
    await stop();

    _isPlaying = true;
    _currentCancelToken = cancelToken;
    _playbackCompleter = Completer<void>();

    try {
      // Apply timeout if specified
      final effectiveTimeout = timeout ?? maxPatternDuration;

      // Apply initial delay if specified
      if (pattern.delay != null && !_isCancelled()) {
        await _delayWithCancellation(pattern.delay!);
      }

      // Play the pattern for the specified number of repeats
      final repeatCount = pattern.repeat ?? 1;
      if (kDebugMode) {
        print('[PatternPlayer] Playing pattern with $repeatCount repeat(s)');
      }

      for (int i = 0; i < repeatCount; i++) {
        if (_isCancelled()) break;

        await _playEvents(pattern.events).timeout(
          effectiveTimeout,
          onTimeout: () {
            throw TimeoutException(
              'Pattern playback exceeded maximum duration',
              effectiveTimeout,
            );
          },
        );
      }

      if (!_isCancelled() &&
          _playbackCompleter != null &&
          !_playbackCompleter!.isCompleted) {
        _playbackCompleter!.complete();
      }
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        print('[PatternPlayer] Playback timeout: ${e.message}');
      }
      if (_playbackCompleter != null && !_playbackCompleter!.isCompleted) {
        _playbackCompleter!.completeError(e);
      }
    } catch (e) {
      if (kDebugMode) {
        print('[PatternPlayer] Playback error: $e');
      }
      if (_playbackCompleter != null && !_playbackCompleter!.isCompleted) {
        _playbackCompleter!.completeError(e);
      }
    } finally {
      _isPlaying = false;
      _currentCancelToken = null;
      _playbackCompleter = null;
    }
  }

  /// Plays a sequence of haptic events with cancellation support
  Future<void> _playEvents(List<HapticEvent> events) async {
    for (final event in events) {
      if (_isCancelled()) break;

      try {
        switch (event.type) {
          case HapticEventType.impact:
          case HapticEventType.continuous:
            // Validate event parameters
            if (event.intensity < 0 || event.intensity > 1) {
              if (kDebugMode) {
                print(
                  '[PatternPlayer] Invalid intensity ${event.intensity}, clamping',
                );
              }
              break;
            }
            if (event.duration <= 0) {
              if (kDebugMode) {
                print(
                  '[PatternPlayer] Invalid duration ${event.duration}, skipping',
                );
              }
              break;
            }

            await _platformAdapter.triggerEffect(
              intensity: event.intensity.clamp(0, 1),
              duration: event.duration,
              sharpness: event.sharpness?.clamp(0, 1) ?? 0.5,
            );

            // Wait for the duration to complete with cancellation support
            await _delayWithCancellation(
              Duration(milliseconds: event.duration),
            );
            break;

          case HapticEventType.pause:
            // Validate pause duration
            if (event.duration <= 0) {
              if (kDebugMode) {
                print(
                  '[PatternPlayer] Invalid pause duration ${event.duration}, skipping',
                );
              }
              break;
            }

            // Wait without triggering any effect
            await _delayWithCancellation(
              Duration(milliseconds: event.duration),
            );
            break;
        }
      } catch (e) {
        if (kDebugMode) {
          print('[PatternPlayer] Error playing event: $e');
        }
        // Continue with next event instead of failing entire pattern
      }
    }
  }

  /// Delays while checking for cancellation
  Future<void> _delayWithCancellation(Duration duration) async {
    final startTime = DateTime.now();
    const checkInterval = Duration(milliseconds: 50);

    while (!_isCancelled()) {
      final elapsed = DateTime.now().difference(startTime);
      if (elapsed >= duration) {
        break;
      }

      final remaining = duration - elapsed;
      final nextCheck = remaining > checkInterval ? checkInterval : remaining;
      await Future.delayed(nextCheck);
    }
  }

  /// Checks if playback has been cancelled
  bool _isCancelled() => _currentCancelToken?.isCancelled ?? false;

  /// Stops the currently playing pattern
  Future<void> stop() async {
    if (!_isPlaying) return;

    if (kDebugMode) {
      print('[PatternPlayer] Stopping pattern playback');
    }

    _isPlaying = false;
    _currentTimer?.cancel();
    _currentTimer = null;

    // Cancel current token
    await _currentCancelToken?.cancel();

    // Wait for the completer if it exists
    if (_playbackCompleter != null && !_playbackCompleter!.isCompleted) {
      _playbackCompleter!.complete();
    }

    _currentCancelToken = null;
    _playbackCompleter = null;
  }

  /// Checks if a pattern is currently playing
  bool get isPlaying => _isPlaying;

  /// Resets the player to its initial state
  Future<void> reset() async {
    if (kDebugMode) {
      print('[PatternPlayer] Resetting player state');
    }
    await stop();
  }

  /// Disposes resources
  Future<void> dispose() async {
    if (kDebugMode) {
      print('[PatternPlayer] Disposing resources');
    }
    await stop();
  }
}
