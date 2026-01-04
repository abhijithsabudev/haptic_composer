import Flutter
import CoreHaptics

public class HapticComposerPlugin: NSObject, FlutterPlugin {
  private var hapticEngine: CHHapticEngine?
  
  public static func dummyMethodToEnforceBundling(_ call: FlutterMethodCall) {
    // This method is intentionally empty but required for the plugin to be bundled
  }

  public static func register(with registrar: FlutterPluginRegistry.FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "com.example.haptic_composer/haptic",
      binaryMessenger: registrar.messenger()
    )
    let instance = HapticComposerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func dummyMethodToEnforceBundling() {
    // This method is intentionally empty but required for the plugin to be bundled
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "initialize":
      initialize(result: result)
    case "triggerEffect":
      triggerEffect(call: call, result: result)
    case "isSupported":
      isSupported(result: result)
    case "dispose":
      dispose(result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func initialize(result: @escaping FlutterResult) {
    do {
      if CHHapticEngine.capabilitiesForHardware().supportsHaptics {
        hapticEngine = try CHHapticEngine(options: [:])
        try hapticEngine?.start()
        result(true)
      } else {
        result(false)
      }
    } catch {
      print("Haptic engine initialization failed: \(error)")
      result(false)
    }
  }

  private func triggerEffect(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let intensity = args["intensity"] as? Double,
          let duration = args["duration"] as? Int else {
      result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
      return
    }

    let sharpness = args["sharpness"] as? Double ?? 0.5

    do {
      var events = [CHHapticEvent]()

      // Create intensity parameter
      let intensityParameter = CHHapticDynamicParameter(
        parameterID: .hapticIntensity,
        value: intensity
      )

      // Create sharpness parameter
      let sharpnessParameter = CHHapticDynamicParameter(
        parameterID: .hapticSharpness,
        value: sharpness
      )

      // Create the haptic event
      let event = CHHapticEvent(
        eventType: .hapticTransient,
        parameters: [intensityParameter, sharpnessParameter],
        relativeTime: 0
      )

      events.append(event)

      // Create the haptic pattern
      let pattern = try CHHapticPattern(events: events, parameters: [])

      // Play the pattern
      try hapticEngine?.start(completionHandler: nil)
      try hapticEngine?.playPattern(pattern)

      result(nil)
    } catch {
      print("Haptic trigger failed: \(error)")
      result(FlutterError(code: "HAPTIC_ERROR", message: "Failed to trigger haptic", details: nil))
    }
  }

  private func isSupported(result: @escaping FlutterResult) {
    result(CHHapticEngine.capabilitiesForHardware().supportsHaptics)
  }

  private func dispose(result: @escaping FlutterResult) {
    do {
      try hapticEngine?.stop()
      hapticEngine = nil
      result(nil)
    } catch {
      result(FlutterError(code: "DISPOSE_ERROR", message: "Failed to dispose haptic engine", details: nil))
    }
  }
}
