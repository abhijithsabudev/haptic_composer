import 'package:flutter/material.dart';
import '../src/models/haptic_pattern.dart';
import '../src/engine/haptic_engine.dart';

/// A wrapper widget that adds haptic feedback to any widget
///
/// HapticFeedback allows you to wrap any widget and trigger haptic
/// patterns on tap, long press, or other interactions.
class HapticFeedback extends StatelessWidget {
  /// The child widget to wrap
  final Widget child;

  /// Haptic pattern to play on tap
  final HapticPattern? onTap;

  /// Haptic pattern to play on long press
  final HapticPattern? onLongPress;

  /// Haptic pattern to play on double tap
  final HapticPattern? onDoubleTap;

  /// Callback when tap starts
  final VoidCallback? onTapDown;

  /// Callback when tap ends
  final VoidCallback? onTapUp;

  /// Callback when tap is cancelled
  final VoidCallback? onTapCancel;

  /// Whether haptic feedback is enabled
  final bool enabled;

  /// Creates a haptic feedback wrapper
  const HapticFeedback({
    required this.child,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.enabled = true,
    super.key,
  }) : assert(
         onTap != null || onLongPress != null || onDoubleTap != null,
         'At least one haptic pattern must be provided',
       );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled && onTap != null ? () => _playHaptic(onTap!) : null,
      onLongPress: enabled && onLongPress != null
          ? () => _playHaptic(onLongPress!)
          : null,
      onDoubleTap: enabled && onDoubleTap != null
          ? () => _playHaptic(onDoubleTap!)
          : null,
      onTapDown: enabled ? (_) => onTapDown?.call() : null,
      onTapUp: enabled ? (_) => onTapUp?.call() : null,
      onTapCancel: enabled ? onTapCancel : null,
      child: child,
    );
  }

  void _playHaptic(HapticPattern pattern) {
    final engine = HapticEngine();
    engine.play(pattern);
  }
}

/// Convenience widget for tap feedback
class TapHaptic extends HapticFeedback {
  /// Creates a tap haptic feedback wrapper
  TapHaptic({
    required Widget child,
    required HapticPattern pattern,
    VoidCallback? onTap,
    bool enabled = true,
    super.key,
  }) : super(child: child, onTap: pattern, enabled: enabled);
}

/// Convenience widget for long press feedback
class LongPressHaptic extends HapticFeedback {
  /// Creates a long press haptic feedback wrapper
  LongPressHaptic({
    required Widget child,
    required HapticPattern pattern,
    VoidCallback? onLongPress,
    bool enabled = true,
    super.key,
  }) : super(child: child, onLongPress: pattern, enabled: enabled);
}
