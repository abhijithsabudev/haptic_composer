# Haptic Composer Architecture

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      Flutter Application                         │
├─────────────────────────────────────────────────────────────────┤
│                    HapticComposer (Main API)                     │
│                 • play(pattern)                                   │
│                 • initialize()                                    │
│                 • stop()                                          │
│                 • isSupported()                                   │
└────────────────────┬────────────────────────────────────────────┘
                     │
        ┌────────────┼────────────┐
        │            │            │
        ▼            ▼            ▼
   ┌─────────┐ ┌──────────┐ ┌─────────┐
   │ Models  │ │  Engine  │ │ Widgets │
   ├─────────┤ ├──────────┤ ├─────────┤
   │ Event   │ │ Singleton│ │ Button  │
   │ Pattern │ │ Platform │ │ Wrapper │
   │ Builder │ │ Player   │ │ Scroll  │
   └────┬────┘ └────┬─────┘ └────┬────┘
        │           │            │
        └───────────┼────────────┘
                    │
        ┌───────────┼───────────┐
        │           │           │
        ▼           ▼           ▼
    ┌────────┐ ┌────────┐ ┌──────────┐
    │ Presets│ │Composer│ │ Utilities│
    ├────────┤ ├────────┤ ├──────────┤
    │ 25+    │ │Visual  │ │Serializer│
    │Patterns│ │UI      │ │Validator │
    └────┬───┘ └────┬───┘ └────┬─────┘
         │          │          │
         └──────────┼──────────┘
                    │
        ┌───────────┼───────────┐
        │           │           │
        ▼           ▼           ▼
    ┌────────┐ ┌────────┐ ┌──────────┐
    │  iOS   │ │Android │ │   Web    │
    │ Core   │ │Vibration│ │Vibration │
    │ Haptics│ │ Effect │ │   API    │
    └────────┘ └────────┘ └──────────┘
```

## Module Dependency Graph

```
┌──────────────────────────────────────────────────────────────┐
│                    haptic_composer.dart                       │
│                   (Main Public API)                           │
└──────────────────┬───────────────────────────────────────────┘
                   │
        ┌──────────┼──────────┬──────────┬──────────┐
        │          │          │          │          │
        ▼          ▼          ▼          ▼          ▼
     Models    Engine      Presets   Widgets    Composer
        │          │          │          │          │
        │          │          │          │          │
        ├─────────┼──────────┼──────────┼──────────┤
        │          │          │          │          │
        ▼          ▼          ▼          ▼          ▼
    ┌─────────────────────────────────────────────┐
    │            Utils (Serializer, Validator)    │
    └─────────────────┬───────────────────────────┘
                      │
            ┌─────────┼─────────┐
            │         │         │
            ▼         ▼         ▼
        ┌────────┐ ┌────────┐ ┌──────────┐
        │  Dart  │ │ Flutter│ │ Imports  │
        │   SDK  │ │   SDK  │ │  Only    │
        └────────┘ └────────┘ └──────────┘
```

## Data Flow: Playing a Pattern

```
User Code
    │
    ├─ HapticComposer.play(pattern)
    │
    ├─ HapticEngine.play(pattern)
    │
    ├─ PatternPlayer._playEvents(events)
    │
    └─┬─ For each HapticEvent:
      │
      ├─ HapticEventType == Impact/Continuous
      │  └─ PlatformAdapter.triggerEffect()
      │     │
      │     ├─ iOS: MethodChannel → HapticComposerPlugin.swift
      │     │  └─ CHHapticEngine.playPattern()
      │     │
      │     └─ Android: MethodChannel → HapticComposerPlugin.kt
      │        └─ Vibrator.vibrate(VibrationEffect)
      │
      ├─ HapticEventType == Pause
      │  └─ Future.delayed(duration)
      │
      └─ Wait for event.duration
         └─ Continue to next event
```

## Class Hierarchy

```
HapticEvent
├─ Type: HapticEventType (impact, continuous, pause)
├─ Intensity: double [0.0, 1.0]
├─ Duration: int (milliseconds)
├─ Sharpness: double? [0.0, 1.0] (iOS only)
└─ Factories:
   ├─ HapticEvent.impact()
   ├─ HapticEvent.continuous()
   └─ HapticEvent.pause()

HapticPattern
├─ Events: List<HapticEvent>
├─ Repeat: int?
├─ Delay: Duration?
├─ Getters:
│  ├─ totalDuration
│  ├─ eventCount
│  └─ isInfinite
└─ Methods:
   ├─ toJson() / fromJson()
   ├─ copyWith()
   └─ builder() → HapticPatternBuilder

HapticPatternBuilder
├─ Methods:
│  ├─ impact() → HapticPatternBuilder
│  ├─ continuous() → HapticPatternBuilder
│  ├─ pause() → HapticPatternBuilder
│  ├─ addEvent() → HapticPatternBuilder
│  ├─ repeat() → HapticPatternBuilder
│  ├─ delay() → HapticPatternBuilder
│  ├─ clear() → HapticPatternBuilder
│  └─ build() → HapticPattern

HapticEngine (Singleton)
├─ Methods:
│  ├─ initialize() → Future<bool>
│  ├─ play(pattern) → Future<void>
│  ├─ stop() → Future<void>
│  ├─ dispose() → Future<void>
│  └─ isHapticFeedbackEnabled() → Future<bool>
├─ Getters:
│  ├─ isPlaying: bool
│  └─ maxEffectDuration: int
└─ Private:
   ├─ _platformAdapter: PlatformAdapter
   └─ _patternPlayer: PatternPlayer

PlatformAdapter
├─ Methods:
│  ├─ initialize() → Future<bool>
│  ├─ triggerEffect() → Future<void>
│  ├─ isSupported() → Future<bool>
│  └─ dispose() → Future<void>
└─ Constants:
   └─ platform: MethodChannel

PatternPlayer
├─ Methods:
│  ├─ play(pattern) → Future<void>
│  ├─ stop() → Future<void>
│  ├─ reset() → Future<void>
│  └─ dispose() → Future<void>
├─ Getters:
│  └─ isPlaying: bool
└─ Private:
   └─ _playEvents(events) → Future<void>

HapticValidator
└─ Static Methods:
   ├─ validate(pattern) → List<String>
   ├─ isValid(pattern) → bool
   ├─ getReport(pattern) → ValidationReport
   └─ normalize(pattern) → HapticPattern

PatternSerializer
└─ Static Methods:
   ├─ toJsonString(pattern) → String
   ├─ fromJsonString(json) → HapticPattern
   ├─ toJson(pattern) → Map
   ├─ fromJson(json) → HapticPattern
   ├─ exportWithMetadata() → Map
   ├─ importFromMetadata() → HapticPattern
   └─ prettyPrint() → String
```

## Platform Channel Protocol

```
Method Channel: "com.example.haptic_composer/haptic"

┌─────────────────────────────────────────────────────────┐
│                  Dart Side (Plugin)                       │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  initialize() ────────────────┐                         │
│                               │                         │
│  triggerEffect()              │ MethodChannel           │
│  ├─ intensity: double         │   Communication        │
│  ├─ duration: int             ├──────────────────────→ │
│  └─ sharpness?: double        │                         │
│                               │                         │
│  isSupported() ───────────────┤                         │
│                               │                         │
│  dispose() ────────────────────┤                         │
│                               │                         │
└───────────────────────────────┼─────────────────────────┘
                                │
                ┌───────────────┼────────────────┐
                │               │                │
                ▼               ▼                ▼
          ┌──────────┐    ┌──────────┐    ┌──────────┐
          │   iOS    │    │ Android  │    │   Web    │
          │(Swift)   │    │(Kotlin)  │    │(JS)      │
          ├──────────┤    ├──────────┤    ├──────────┤
          │CoreHaptic│    │Vibrator  │    │Vibration │
          │s Engine  │    │Effect    │    │API       │
          └──────────┘    └──────────┘    └──────────┘
```

## State Diagram: Pattern Playback

```
           ┌──────────────┐
           │   Idle       │
           │(Not Playing) │
           └──────┬───────┘
                  │
                  │ play(pattern)
                  │
           ┌──────▼────────┐
           │   Initializing│
           │ (Setup/Delay) │
           └──────┬────────┘
                  │
                  │ start playback
                  │
           ┌──────▼────────┐
        ┌─→│   Playing     │◄──┐
        │  │(Event Loop)  │   │
        │  └──────┬────────┘   │
        │         │            │
        │         ├─ next event │
        │         │            │
        │         └────────────┘
        │
        │ all events done
        │
        │  ┌──────────────┐
        └──┤  Completed   │
           └──────┬───────┘
                  │
                  │ pattern.repeat > 0?
                  │
           ┌──────┴───────┐
        Yes│              │No
           │              │
           ▼              ▼
        Playing         Idle
        (repeat)
```

## Threading Model

```
UI Thread (Main)
│
├─ HapticComposer.play(pattern)
│  └─ Returns Future<void>
│
└─ PatternPlayer._playEvents()
   └─ Uses Future.delayed() for timing
      (Non-blocking async operations)
      
No separate threads used - all timing handled
through Dart async/await and Future APIs.
Platform calls use async method channels.
```

## Integration Points

### 1. **Widget Integration**
- Widgets listen to user gestures
- Call `HapticComposer.play()` on interaction
- No blocking - async operations

### 2. **Platform Communication**
- Dart → MethodChannel → Swift/Kotlin
- Haptic parameters passed as Map
- Platform executes and completes async

### 3. **Lifecycle**
- Initialize: App startup
- Play: On demand
- Dispose: App shutdown

## Error Handling Flow

```
User Action
    │
    ├─ HapticComposer.play()
    │
    ├─ Validate pattern (optional)
    │  ├─ If invalid → Log/handle error
    │  └─ If valid → Continue
    │
    ├─ Check support
    │  ├─ If not supported → Silently skip
    │  └─ If supported → Continue
    │
    ├─ Trigger platform effect
    │  ├─ If error → Silently fail
    │  └─ If success → Complete
    │
    └─ Return to user
```

---

This architecture provides:
- ✅ Clear separation of concerns
- ✅ Singleton pattern for engine
- ✅ Async-first design
- ✅ Platform abstraction
- ✅ Null safety
- ✅ Error resilience
- ✅ Easy to extend
