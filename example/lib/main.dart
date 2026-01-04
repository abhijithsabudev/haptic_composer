import 'package:flutter/material.dart';
import 'package:haptic_composer/haptic_composer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HapticComposer.initialize();
  runApp(const HapticComposerExampleApp());
}

class HapticComposerExampleApp extends StatelessWidget {
  const HapticComposerExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Haptic Composer Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Haptic Composer Demo'),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          PatternGalleryScreen(),
          PatternBuilderScreen(),
          ComposerScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            label: 'Gallery',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Builder'),
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            label: 'Composer',
          ),
        ],
      ),
    );
  }
}

class PatternGalleryScreen extends StatelessWidget {
  const PatternGalleryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SectionHeader('Feedback Patterns'),
        PatternTile(
          name: 'Success',
          description: 'Double tap with increasing intensity',
          pattern: HapticPresets.success,
        ),
        PatternTile(
          name: 'Error',
          description: 'Triple short bursts',
          pattern: HapticPresets.error,
        ),
        PatternTile(
          name: 'Warning',
          description: 'Single strong pulse',
          pattern: HapticPresets.warning,
        ),
        PatternTile(
          name: 'Notification',
          description: 'Ascending intensity',
          pattern: HapticPresets.notification,
        ),
        const SizedBox(height: 24),
        const SectionHeader('Interaction Patterns'),
        PatternTile(
          name: 'Button Press',
          description: 'Quick, sharp impact',
          pattern: HapticPresets.buttonPress,
        ),
        PatternTile(
          name: 'Toggle',
          description: 'Soft double tap',
          pattern: HapticPresets.toggle,
        ),
        PatternTile(
          name: 'Long Press',
          description: 'Building intensity',
          pattern: HapticPresets.longPress,
        ),
        PatternTile(
          name: 'Swipe',
          description: 'Smooth continuous effect',
          pattern: HapticPresets.swipe,
        ),
        const SizedBox(height: 24),
        const SectionHeader('Advanced Patterns'),
        PatternTile(
          name: 'Heartbeat',
          description: 'Natural pulse rhythm',
          pattern: HapticPresets.heartbeat,
        ),
        PatternTile(
          name: 'Pulse',
          description: 'Breathing effect',
          pattern: HapticPresets.pulse,
        ),
        PatternTile(
          name: 'Drumroll',
          description: 'Rapid succession',
          pattern: HapticPresets.drumroll,
        ),
        PatternTile(
          name: 'Ripple',
          description: 'Decreasing waves',
          pattern: HapticPresets.ripple,
        ),
      ],
    );
  }
}

class PatternBuilderScreen extends StatefulWidget {
  const PatternBuilderScreen({Key? key}) : super(key: key);

  @override
  State<PatternBuilderScreen> createState() => _PatternBuilderScreenState();
}

class _PatternBuilderScreenState extends State<PatternBuilderScreen> {
  late HapticPattern _pattern;

  @override
  void initState() {
    super.initState();
    _pattern = HapticPattern.builder()
        .impact(intensity: 0.8, duration: 50)
        .pause(100)
        .impact(intensity: 0.5, duration: 30)
        .build();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Build Your Pattern',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  'Current Pattern:',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _pattern.toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _playPattern,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Play'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _resetPattern,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Quick Patterns',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildQuickPattern(
          'Light Tap',
          () => _setPattern(
            HapticPattern.builder()
                .impact(intensity: 0.3, duration: 20)
                .build(),
          ),
        ),
        _buildQuickPattern(
          'Medium Double Tap',
          () => _setPattern(
            HapticPattern.builder()
                .impact(intensity: 0.5, duration: 30)
                .pause(40)
                .impact(intensity: 0.5, duration: 30)
                .build(),
          ),
        ),
        _buildQuickPattern(
          'Strong Triple Tap',
          () => _setPattern(
            HapticPattern.builder()
                .impact(intensity: 0.8, duration: 40)
                .pause(50)
                .impact(intensity: 0.8, duration: 40)
                .pause(50)
                .impact(intensity: 0.8, duration: 40)
                .build(),
          ),
        ),
        _buildQuickPattern(
          'Pulse Wave',
          () => _setPattern(
            HapticPattern.builder()
                .impact(intensity: 0.4, duration: 30)
                .pause(60)
                .impact(intensity: 0.6, duration: 40)
                .pause(60)
                .impact(intensity: 0.8, duration: 50)
                .build(),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickPattern(String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
        child: Text(label),
      ),
    );
  }

  void _playPattern() async {
    await HapticComposer.play(_pattern);
  }

  void _setPattern(HapticPattern pattern) {
    setState(() => _pattern = pattern);
  }

  void _resetPattern() {
    _setPattern(
      HapticPattern.builder()
          .impact(intensity: 0.8, duration: 50)
          .pause(100)
          .impact(intensity: 0.5, duration: 30)
          .build(),
    );
  }
}

class ComposerScreen extends StatelessWidget {
  const ComposerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HapticComposerUI(
      onPatternChanged: (pattern) {
        // Pattern updated, no need to show snackbar
      },
      onPlay: (pattern) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Playing pattern...')));
      },
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader(this.title, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }
}

class PatternTile extends StatefulWidget {
  final String name;
  final String description;
  final HapticPattern pattern;

  const PatternTile({
    required this.name,
    required this.description,
    required this.pattern,
    Key? key,
  }) : super(key: key);

  @override
  State<PatternTile> createState() => _PatternTileState();
}

class _PatternTileState extends State<PatternTile> {
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(widget.name),
        subtitle: Text(widget.description),
        trailing: ElevatedButton.icon(
          onPressed: _isPlaying ? null : _playPattern,
          icon: _isPlaying
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.play_arrow),
          label: Text(_isPlaying ? 'Playing...' : 'Play'),
        ),
      ),
    );
  }

  Future<void> _playPattern() async {
    setState(() => _isPlaying = true);
    try {
      await HapticComposer.play(widget.pattern);
    } finally {
      if (mounted) {
        setState(() => _isPlaying = false);
      }
    }
  }
}
