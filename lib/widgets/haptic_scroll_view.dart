import 'package:flutter/material.dart';
import '../src/models/haptic_pattern.dart';
import '../src/engine/haptic_engine.dart';

/// A ScrollView that provides haptic feedback on scroll events
///
/// HapticScrollView wraps a standard scroll view and provides haptic
/// feedback for various scroll interactions like overscroll and snap-to-item.
class HapticScrollView extends StatefulWidget {
  /// The list of child widgets to scroll through
  final List<Widget> children;

  /// Haptic pattern to play on overscroll
  final HapticPattern? onOverscroll;

  /// Haptic pattern to play when snapping to an item
  final HapticPattern? onSnapToItem;

  /// Haptic pattern to play when scrolling
  final HapticPattern? onScroll;

  /// Scroll direction
  final Axis scrollDirection;

  /// Whether scrolling is reversed
  final bool reverse;

  /// Controller for the scroll view
  final ScrollController? controller;

  /// Physics for the scroll view
  final ScrollPhysics? physics;

  /// Padding around the scroll view
  final EdgeInsets padding;

  /// Creates a haptic scroll view
  const HapticScrollView({
    required this.children,
    this.onOverscroll,
    this.onSnapToItem,
    this.onScroll,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.physics,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  @override
  State<HapticScrollView> createState() => _HapticScrollViewState();
}

class _HapticScrollViewState extends State<HapticScrollView> {
  late ScrollController _scrollController;
  final _hapticEngine = HapticEngine();
  bool _canPlayScroll = true;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;

    // Check for overscroll
    if (position.outOfRange) {
      if (widget.onOverscroll != null) {
        _hapticEngine.play(widget.onOverscroll!);
      }
    }

    // Throttle scroll feedback
    if (_canPlayScroll && widget.onScroll != null) {
      _hapticEngine.play(widget.onScroll!);
      _canPlayScroll = false;
      Future.delayed(Duration(milliseconds: 100), () {
        _canPlayScroll = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      controller: _scrollController,
      physics: widget.physics,
      padding: widget.padding,
      children: widget.children,
    );
  }
}

/// A custom scroll view with haptic feedback
class HapticCustomScrollView extends StatefulWidget {
  /// The slivers to display
  final List<Widget> slivers;

  /// Haptic pattern to play on overscroll
  final HapticPattern? onOverscroll;

  /// Haptic pattern to play when snapping to an item
  final HapticPattern? onSnapToItem;

  /// Scroll direction
  final Axis scrollDirection;

  /// Controller for the scroll view
  final ScrollController? controller;

  /// Physics for the scroll view
  final ScrollPhysics? physics;

  /// Creates a haptic custom scroll view
  const HapticCustomScrollView({
    required this.slivers,
    this.onOverscroll,
    this.onSnapToItem,
    this.scrollDirection = Axis.vertical,
    this.controller,
    this.physics,
    super.key,
  });

  @override
  State<HapticCustomScrollView> createState() => _HapticCustomScrollViewState();
}

class _HapticCustomScrollViewState extends State<HapticCustomScrollView> {
  late ScrollController _scrollController;
  final _hapticEngine = HapticEngine();

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;

    // Check for overscroll
    if (position.outOfRange && widget.onOverscroll != null) {
      _hapticEngine.play(widget.onOverscroll!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      scrollDirection: widget.scrollDirection,
      controller: _scrollController,
      physics: widget.physics,
      slivers: widget.slivers,
    );
  }
}
