import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/haptic_pattern.dart';
import 'platform_adapter.dart';
import 'pattern_player.dart';

/// Token for cancelling ongoing haptic operations
class CancelToken {
  bool _cancelled = false;

  /// Returns true if cancellation has been requested
  bool get isCancelled => _cancelled;

  /// Cancels the operation
  Future<void> cancel() async {
    _cancelled = true;
  }
}

/// Callback for handling haptic playback completion
typedef OnHapticComplete = void Function();

/// Callback for handling haptic playback errors
typedef OnHapticError = void Function(String error);

/// The main haptic engine that manages haptic playback
///
/// This is the core component that handles playing haptic patterns
/// across different platforms. It manages platform communication and
/// pattern playback with comprehensive error handling, cancellation support,
/// and edge case management.
class HapticEngine {
  static final HapticEngine _instance = HapticEngine._internal();
  late final PlatformAdapter _platformAdapter;
  late final PatternPlayer _patternPlayer;

  /// State tracking
  bool _initialized = false;
  bool _disposed = false;
  CancelToken? _currentPlayToken;

  /// Callbacks
  OnHapticComplete? _onComplete;
  OnHapticError? _onError;

  /// Private constructor for singleton pattern
  HapticEngine._internal() {
    _platformAdapter = PlatformAdapter();
    _patternPlayer = PatternPlayer(_platformAdapter);
  }

  /// Gets the singleton instance of the haptic engine
  factory HapticEngine() {
    return _instance;
  }

  /// Checks if the engine is initialized
  bool get isInitialized => _initialized;

  /// Checks if the engine has been disposed
  bool get isDisposed => _disposed;

  /// Initializes the haptic engine
  ///
  /// This should be called once at app startup.
  /// Returns true if initialization was successful.
  /// Throws [StateError] if engine is already disposed.
  Future<bool> initialize() async {
    if (_disposed) {
      throw StateError('Cannot initialize a disposed HapticEngine');
    }

    if (_initialized) {
      if (kDebugMode) {
        print('[HapticEngine] Already initialized, skipping re-initialization');
      }
      return true;
    }

    try {
      final success = await _platformAdapter.initialize();
      // Mark as initialized regardless of platform success
      // This allows graceful fallback if platform doesn't support haptics
      _initialized = true;

      if (success) {
        if (kDebugMode) {
          print('[HapticEngine] Initialization successful');
        }
      } else {
        if (kDebugMode) {
          print(
            '[HapticEngine] Platform does not support haptics, but initialized',
          );
        }
      }
      return success;
    } catch (e) {
      if (kDebugMode) {
        print('[HapticEngine] Initialization error: $e');
      }
      // Mark as initialized to allow graceful degradation
      _initialized = true;
      _onError?.call('Initialization failed: $e');
      return false;
    }
  }

  /// Plays a single haptic pattern with optional callbacks
  ///
  /// Returns a future that completes when the pattern finishes playing.
  /// If engine is not initialized, will attempt to initialize first.
  /// Throws [ArgumentError] if pattern is invalid.
  Future<void> play(
    HapticPattern pattern, {
    OnHapticComplete? onComplete,
    OnHapticError? onError,
  }) async {
    if (_disposed) {
      throw StateError('Cannot play on a disposed HapticEngine');
    }

    // If not initialized, attempt initialization
    if (!_initialized) {
      if (kDebugMode) {
        print('[HapticEngine] Engine not initialized, initializing now...');
      }
      await initialize();
    }

    // Validate pattern
    if (pattern.events.isEmpty) {
      final error = 'Cannot play empty pattern';
      if (kDebugMode) {
        print('[HapticEngine] Error: $error');
      }
      onError?.call(error);
      _onError?.call(error);
      return;
    }

    try {
      // Cancel any previously playing pattern
      await _currentPlayToken?.cancel();

      // Create cancellation token for this playback
      _currentPlayToken = CancelToken();

      if (kDebugMode) {
        print(
          '[HapticEngine] Playing pattern with ${pattern.events.length} events',
        );
      }

      // Play the pattern
      await _patternPlayer.play(pattern, cancelToken: _currentPlayToken);

      // Call completion callback
      if (!(_currentPlayToken?.isCancelled ?? false)) {
        onComplete?.call();
        _onComplete?.call();
        if (kDebugMode) {
          print('[HapticEngine] Pattern playback completed');
        }
      }
    } on TimeoutException catch (e) {
      final error = 'Playback timeout: $e';
      if (kDebugMode) {
        print('[HapticEngine] Error: $error');
      }
      onError?.call(error);
      _onError?.call(error);
    } catch (e) {
      final error = 'Playback error: $e';
      if (kDebugMode) {
        print('[HapticEngine] Error: $error');
      }
      onError?.call(error);
      _onError?.call(error);
    }
  }

  /// Stops the currently playing pattern
  ///
  /// Safely stops playback and cancels pending operations.
  Future<void> stop() async {
    if (_disposed) {
      if (kDebugMode) {
        print('[HapticEngine] Stop called on disposed engine, ignoring');
      }
      return;
    }

    try {
      // Cancel current playback
      await _currentPlayToken?.cancel();
      _currentPlayToken = null;

      // Stop pattern player
      await _patternPlayer.stop();

      if (kDebugMode) {
        print('[HapticEngine] Pattern playback stopped');
      }
    } catch (e) {
      final error = 'Stop error: $e';
      if (kDebugMode) {
        print('[HapticEngine] Error: $error');
      }
      _onError?.call(error);
    }
  }

  /// Checks if a pattern is currently playing
  bool get isPlaying => _patternPlayer.isPlaying;

  /// Sets callbacks for playback events
  void setCallbacks({OnHapticComplete? onComplete, OnHapticError? onError}) {
    _onComplete = onComplete;
    _onError = onError;
  }

  /// Disposes resources used by the engine
  ///
  /// Should be called when the app is shutting down.
  /// After disposal, the engine cannot be used.
  Future<void> dispose() async {
    if (_disposed) {
      if (kDebugMode) {
        print('[HapticEngine] Already disposed, skipping re-disposal');
      }
      return;
    }

    try {
      // Cancel any playing pattern
      await _currentPlayToken?.cancel();
      _currentPlayToken = null;

      // Dispose pattern player
      await _patternPlayer.dispose();

      // Dispose platform adapter
      await _platformAdapter.dispose();

      _disposed = true;
      _initialized = false;
      _onComplete = null;
      _onError = null;

      if (kDebugMode) {
        print('[HapticEngine] Engine disposed successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[HapticEngine] Disposal error: $e');
      }
    }
  }

  /// Gets the platform adapter (for advanced use cases)
  PlatformAdapter get platformAdapter => _platformAdapter;

  /// Gets the pattern player (for advanced use cases)
  PatternPlayer get patternPlayer => _patternPlayer;

  /// Checks if haptic feedback is supported on the device
  Future<bool> isHapticFeedbackEnabled() async {
    if (_disposed) {
      return false;
    }

    try {
      return await _platformAdapter.isSupported();
    } catch (e) {
      if (kDebugMode) {
        print('[HapticEngine] Error checking haptic support: $e');
      }
      return false;
    }
  }

  /// Gets the maximum duration a single haptic effect can last (in milliseconds)
  int get maxEffectDuration => _platformAdapter.maxEffectDuration;

  /// Resets the engine to initial state
  ///
  /// Cancels any playing patterns and clears state.
  Future<void> reset() async {
    if (_disposed) {
      if (kDebugMode) {
        print('[HapticEngine] Reset called on disposed engine, ignoring');
      }
      return;
    }

    try {
      await _currentPlayToken?.cancel();
      _currentPlayToken = null;
      await _patternPlayer.reset();

      if (kDebugMode) {
        print('[HapticEngine] Engine reset successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[HapticEngine] Reset error: $e');
      }
      _onError?.call('Reset error: $e');
    }
  }
}
