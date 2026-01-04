import 'package:flutter/material.dart';
import '../models/haptic_pattern.dart';
import '../models/haptic_event.dart';
import '../engine/haptic_engine.dart';

/// A visual UI widget for composing haptic patterns
///
/// HapticComposerUI provides an interactive interface for designing,
/// editing, and previewing haptic patterns. It includes a timeline view,
/// intensity curve editor, and real-time preview capabilities.
class HapticComposerUI extends StatefulWidget {
  /// The initial pattern to edit
  final HapticPattern? initialPattern;

  /// Callback when the pattern changes
  final ValueChanged<HapticPattern>? onPatternChanged;

  /// Callback when the user wants to play the pattern
  final ValueChanged<HapticPattern>? onPlay;

  /// Whether to allow exporting the pattern
  final bool allowExport;

  /// Creates a haptic composer UI widget
  const HapticComposerUI({
    this.initialPattern,
    this.onPatternChanged,
    this.onPlay,
    this.allowExport = true,
    super.key,
  });

  @override
  State<HapticComposerUI> createState() => _HapticComposerUIState();
}

class _HapticComposerUIState extends State<HapticComposerUI> {
  late List<HapticEvent> _events;
  late int _selectedEventIndex;
  final _hapticEngine = HapticEngine();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _events = widget.initialPattern?.events.toList() ?? [];
    _selectedEventIndex = -1;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Timeline view
          _buildTimeline(),
          const SizedBox(height: 16),

          // Controls
          _buildControls(),
          const SizedBox(height: 16),

          // Event editor
          if (_selectedEventIndex >= 0) _buildEventEditor(),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Timeline (${_events.length} events)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 150,
              child: _events.isEmpty
                  ? Center(
                      child: Text(
                        'No events. Tap + to add one.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _events.length,
                      itemBuilder: (context, index) {
                        final event = _events[index];
                        final isSelected = index == _selectedEventIndex;

                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedEventIndex = index);
                          },
                          child: Container(
                            width: 60,
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blue
                                  : _getEventColor(event.type),
                              border: Border.all(
                                color: isSelected ? Colors.blue : Colors.grey,
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  event.type
                                      .toString()
                                      .split('.')
                                      .last[0]
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${event.duration}ms',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ElevatedButton.icon(
          onPressed: _isPlaying ? null : _playPattern,
          icon: const Icon(Icons.play_arrow),
          label: const Text('Play'),
        ),
        ElevatedButton.icon(
          onPressed: _isPlaying ? _stopPattern : null,
          icon: const Icon(Icons.stop),
          label: const Text('Stop'),
        ),
        ElevatedButton.icon(
          onPressed: _addEvent,
          icon: const Icon(Icons.add),
          label: const Text('Add Event'),
        ),
        if (_selectedEventIndex >= 0)
          ElevatedButton.icon(
            onPressed: _removeEvent,
            icon: const Icon(Icons.delete),
            label: const Text('Delete'),
          ),
      ],
    );
  }

  Widget _buildEventEditor() {
    final event = _events[_selectedEventIndex];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Event ${_selectedEventIndex + 1}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),

              // Event type dropdown
              DropdownButton<HapticEventType>(
                value: event.type,
                onChanged: (newType) {
                  if (newType != null) {
                    setState(() {
                      _events[_selectedEventIndex] = HapticEvent(
                        type: newType,
                        intensity: event.intensity,
                        duration: event.duration,
                        sharpness: event.sharpness,
                      );
                      _notifyChange();
                    });
                  }
                },
                items: HapticEventType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.toString().split('.').last),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),

              // Intensity slider
              _buildSlider(
                label:
                    'Intensity: ${(event.intensity * 100).toStringAsFixed(0)}%',
                value: event.intensity,
                onChanged: (value) {
                  setState(() {
                    _events[_selectedEventIndex] = HapticEvent(
                      type: event.type,
                      intensity: value,
                      duration: event.duration,
                      sharpness: event.sharpness,
                    );
                    _notifyChange();
                  });
                },
              ),
              const SizedBox(height: 16),

              // Duration slider (100ms to 5000ms)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Duration: ${event.duration}ms',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Slider(
                    value: event.duration.toDouble(),
                    onChanged: (value) {
                      setState(() {
                        _events[_selectedEventIndex] = HapticEvent(
                          type: event.type,
                          intensity: event.intensity,
                          duration: value.toInt(),
                          sharpness: event.sharpness,
                        );
                        _notifyChange();
                      });
                    },
                    min: 100.0,
                    max: 5000.0,
                    divisions: 98,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Sharpness slider (if applicable)
              if (event.sharpness != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sharpness: ${(event.sharpness! * 100).toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Slider(
                      value: event.sharpness ?? 0.5,
                      onChanged: (value) {
                        setState(() {
                          _events[_selectedEventIndex] = HapticEvent(
                            type: event.type,
                            intensity: event.intensity,
                            duration: event.duration,
                            sharpness: value,
                          );
                          _notifyChange();
                        });
                      },
                      min: 0.0,
                      max: 1.0,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Slider(value: value, onChanged: onChanged, min: 0.0, max: 1.0),
      ],
    );
  }

  void _addEvent() {
    setState(() {
      _events.add(HapticEvent.impact(intensity: 0.5, duration: 100));
      _selectedEventIndex = _events.length - 1;
      _notifyChange();
    });
  }

  void _removeEvent() {
    if (_selectedEventIndex >= 0 && _selectedEventIndex < _events.length) {
      setState(() {
        _events.removeAt(_selectedEventIndex);
        _selectedEventIndex = -1;
        _notifyChange();
      });
    }
  }

  void _notifyChange() {
    if (_events.isNotEmpty) {
      final pattern = HapticPattern(events: _events);
      widget.onPatternChanged?.call(pattern);
    }
  }

  Future<void> _playPattern() async {
    if (_events.isEmpty) return;

    setState(() => _isPlaying = true);

    try {
      final pattern = HapticPattern(events: _events);
      await _hapticEngine.play(pattern);
      widget.onPlay?.call(pattern);
    } finally {
      if (mounted) {
        setState(() => _isPlaying = false);
      }
    }
  }

  Future<void> _stopPattern() async {
    await _hapticEngine.stop();
    setState(() => _isPlaying = false);
  }

  Color _getEventColor(HapticEventType type) {
    switch (type) {
      case HapticEventType.impact:
        return Colors.red;
      case HapticEventType.continuous:
        return Colors.green;
      case HapticEventType.pause:
        return Colors.grey;
    }
  }
}
