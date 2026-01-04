import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Adapter for platform-specific haptic implementations
///
/// This handles communication with native iOS and Android code
/// to trigger haptic feedback with comprehensive error handling
/// and retry logic.
class PlatformAdapter {
  static const platform = MethodChannel('com.example.haptic_composer/haptic');

  /// Retry configuration
  static const int maxRetries = 2;
  static const Duration retryDelay = Duration(milliseconds: 100);

  bool _initialized = false;
  bool _disposed = false;

  /// Initializes the platform adapter
  ///
  /// Returns true if initialization was successful.
  /// Throws [StateError] if already disposed.
  Future<bool> initialize() async {
    if (_disposed) {
      throw StateError('Cannot initialize a disposed PlatformAdapter');
    }

    if (_initialized) {
      if (kDebugMode) {
        print('[PlatformAdapter] Already initialized, skipping');
      }
      return true;
    }

    try {
      final bool isSupported =
          await _invokeMethodWithRetry<bool>('initialize') ?? false;

      // Mark as initialized regardless of support to prevent repeated attempts
      _initialized = true;

      if (isSupported) {
        if (kDebugMode) {
          print('[PlatformAdapter] Initialization successful');
        }
      } else {
        if (kDebugMode) {
          print('[PlatformAdapter] Platform does not support haptics');
        }
      }

      return isSupported;
    } on PlatformException catch (e) {
      // Mark as initialized to prevent repeated retry attempts
      _initialized = true;

      if (kDebugMode) {
        print(
          '[PlatformAdapter] PlatformException during initialization: ${e.code}',
        );
      }
      return false;
    } catch (e) {
      // Mark as initialized to prevent repeated retry attempts
      _initialized = true;

      if (kDebugMode) {
        print('[PlatformAdapter] Haptics not available on this platform');
      }
      return false;
    }
  }

  /// Triggers a haptic effect on the platform with validation and error handling
  ///
  /// Parameters:
  /// - intensity: 0.0 to 1.0
  /// - duration: in milliseconds (1-10000)
  /// - sharpness: 0.0 to 1.0 (iOS only)
  Future<void> triggerEffect({
    required double intensity,
    required int duration,
    double? sharpness,
  }) async {
    if (_disposed) {
      if (kDebugMode) {
        print('[PlatformAdapter] Ignoring trigger on disposed adapter');
      }
      return;
    }

    if (!_initialized) {
      final initialized = await initialize();
      if (!initialized) {
        if (kDebugMode) {
          print('[PlatformAdapter] Haptics unavailable, skipping trigger');
        }
        return;
      }
    }

    // Validate and clamp parameters
    final validIntensity = intensity.clamp(0.0, 1.0);
    final validDuration = duration.clamp(1, maxEffectDuration);
    final validSharpness = sharpness?.clamp(0.0, 1.0) ?? 0.5;

    if (validIntensity != intensity ||
        validDuration != duration ||
        (sharpness != null && validSharpness != sharpness)) {
      if (kDebugMode) {
        print(
          '[PlatformAdapter] Parameter out of range, clamping: intensity=$intensity→$validIntensity, duration=$duration→$validDuration, sharpness=$sharpness→$validSharpness',
        );
      }
    }

    try {
      await _invokeMethodWithRetry('triggerEffect', {
        'intensity': validIntensity,
        'duration': validDuration,
        if (Platform.isIOS) 'sharpness': validSharpness,
      });
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(
          '[PlatformAdapter] PlatformException during triggerEffect: ${e.code} - ${e.message}',
        );
      }
      // Haptics are non-critical, continue silently
    } catch (e) {
      if (kDebugMode) {
        print('[PlatformAdapter] Error triggering effect: $e');
      }
      // Haptics are non-critical, continue silently
    }
  }

  /// Checks if the device supports haptic feedback
  Future<bool> isSupported() async {
    if (_disposed) {
      if (kDebugMode) {
        print('[PlatformAdapter] isSupported called on disposed adapter');
      }
      return false;
    }

    try {
      final bool supported =
          await _invokeMethodWithRetry<bool>('isSupported') ?? false;

      if (kDebugMode) {
        print('[PlatformAdapter] Haptic feedback supported: $supported');
      }

      return supported;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(
          '[PlatformAdapter] PlatformException checking support: ${e.code} - ${e.message}',
        );
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('[PlatformAdapter] Error checking haptic support: $e');
      }
      return false;
    }
  }

  /// Invokes a platform method with retry logic
  ///
  /// Automatically retries failed calls up to [maxRetries] times.
  Future<T?> _invokeMethodWithRetry<T>(
    String method, [
    dynamic arguments,
  ]) async {
    int attempts = 0;
    dynamic lastException;

    while (attempts < maxRetries + 1) {
      try {
        if (kDebugMode && attempts > 0) {
          print(
            '[PlatformAdapter] Retry attempt ${attempts + 1}/${maxRetries + 1} for $method',
          );
        }

        return await platform.invokeMethod<T>(method, arguments);
      } on PlatformException catch (e) {
        lastException = e;
        if (kDebugMode) {
          print(
            '[PlatformAdapter] PlatformException on attempt ${attempts + 1}: ${e.code}',
          );
        }

        // Don't retry on certain error codes
        if (e.code == 'UNSUPPORTED' || e.code == 'NO_FEATURE') {
          rethrow;
        }

        attempts++;
        if (attempts <= maxRetries) {
          await Future.delayed(retryDelay * attempts);
        }
      } on MissingPluginException catch (e) {
        lastException = e;
        if (kDebugMode) {
          print('[PlatformAdapter] Plugin not implemented');
        }
        rethrow; // Don't retry missing plugin
      } catch (e) {
        lastException = e;
        if (kDebugMode) {
          print('[PlatformAdapter] Error on attempt ${attempts + 1}: $e');
        }

        attempts++;
        if (attempts <= maxRetries) {
          await Future.delayed(retryDelay * attempts);
        }
      }
    }

    if (lastException != null) {
      throw lastException;
    }

    return null;
  }

  /// Gets the maximum effect duration supported (in milliseconds)
  int get maxEffectDuration {
    if (Platform.isIOS) {
      return 5000; // iOS Core Haptics supports up to 5 seconds
    } else if (Platform.isAndroid) {
      return 10000; // Android VibrationEffect supports longer durations
    }
    return 1000; // Default fallback
  }

  /// Gets the minimum effect duration (in milliseconds)
  int get minEffectDuration => 1;

  /// Checks if initialized
  bool get isInitialized => _initialized;

  /// Checks if disposed
  bool get isDisposed => _disposed;

  /// Disposes resources
  Future<void> dispose() async {
    if (_disposed) {
      if (kDebugMode) {
        print('[PlatformAdapter] Already disposed, skipping');
      }
      return;
    }

    try {
      await platform.invokeMethod('dispose');
      if (kDebugMode) {
        print('[PlatformAdapter] Disposed successfully');
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('[PlatformAdapter] PlatformException during disposal: ${e.code}');
      }
      // Ignore errors during cleanup
    } catch (e) {
      if (kDebugMode) {
        print('[PlatformAdapter] Error during disposal: $e');
      }
      // Ignore errors during cleanup
    } finally {
      _disposed = true;
      _initialized = false;
    }
  }
}
