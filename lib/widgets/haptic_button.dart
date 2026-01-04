import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../src/models/haptic_pattern.dart';
import '../src/engine/haptic_engine.dart';

/// Callback for handling haptic button errors
typedef OnHapticButtonError = void Function(String error);

/// A button widget that provides haptic feedback on press
///
/// HapticButton wraps a standard button with haptic feedback capabilities.
/// It plays a haptic pattern whenever the button is pressed. Includes
/// comprehensive error handling and lifecycle management.
class HapticButton extends StatefulWidget {
  /// The callback when the button is pressed
  final VoidCallback onPressed;

  /// The haptic pattern to play when button is pressed
  final HapticPattern pattern;

  /// The child widget to display as the button content
  final Widget child;

  /// Optional callback after haptic feedback completes
  final VoidCallback? onHapticComplete;

  /// Optional callback for handling errors
  final OnHapticButtonError? onError;

  /// Whether the button is enabled
  final bool enabled;

  /// Button styling
  final ButtonStyle? style;

  /// Timeout for haptic playback (defaults to 5 seconds)
  final Duration hapticTimeout;

  /// Creates a haptic button with comprehensive error handling
  const HapticButton({
    required this.onPressed,
    required this.pattern,
    required this.child,
    this.onHapticComplete,
    this.onError,
    this.enabled = true,
    this.style,
    this.hapticTimeout = const Duration(seconds: 5),
    super.key,
  });

  @override
  State<HapticButton> createState() => _HapticButtonState();
}

class _HapticButtonState extends State<HapticButton> {
  final _hapticEngine = HapticEngine();
  bool _isLoading = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeEngine();
  }

  /// Initializes the haptic engine
  Future<void> _initializeEngine() async {
    if (_initialized) return;

    try {
      final success = await _hapticEngine.initialize();
      if (mounted) {
        setState(() => _initialized = success);
      }

      if (!success && kDebugMode) {
        print('[HapticButton] Failed to initialize haptic engine');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[HapticButton] Error initializing haptic engine: $e');
      }
      widget.onError?.call('Failed to initialize: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.enabled && !_isLoading ? _handlePress : null,
      style: widget.style,
      child: widget.child,
    );
  }

  Future<void> _handlePress() async {
    if (!mounted) return;

    // Ensure engine is initialized
    if (!_initialized) {
      await _initializeEngine();
      if (!_initialized) {
        widget.onError?.call('Haptic engine not available');
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      // Validate pattern
      if (widget.pattern.isEmpty) {
        throw ArgumentError('Cannot play empty pattern');
      }

      // Play haptic feedback with timeout
      await _hapticEngine
          .play(widget.pattern)
          .timeout(
            widget.hapticTimeout,
            onTimeout: () {
              throw TimeoutException(
                'Haptic feedback timeout',
                widget.hapticTimeout,
              );
            },
          );

      if (!mounted) return;

      // Call user callback
      try {
        widget.onPressed();
      } catch (e) {
        if (kDebugMode) {
          print('[HapticButton] Error in onPressed callback: $e');
        }
        widget.onError?.call('Button press callback failed: $e');
        rethrow;
      }

      // Call completion callback
      widget.onHapticComplete?.call();

      if (kDebugMode) {
        print('[HapticButton] Haptic feedback completed successfully');
      }
    } on TimeoutException catch (e) {
      final error = 'Haptic feedback timeout: ${e.message}';
      if (kDebugMode) {
        print('[HapticButton] $error');
      }
      widget.onError?.call(error);
    } catch (e) {
      final error = 'Haptic feedback error: $e';
      if (kDebugMode) {
        print('[HapticButton] $error');
      }
      widget.onError?.call(error);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    // Don't dispose the engine as it's a singleton
    // shared across the app
    super.dispose();
  }
}
