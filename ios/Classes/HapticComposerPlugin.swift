import Flutter
import UIKit

public class HapticComposerPlugin: NSObject, FlutterPlugin {
  
  public static func dummyMethodToEnforceBundling(_ call: FlutterMethodCall) {
    // This method is intentionally empty but required for the plugin to be bundled
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
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
    result(true)
  }

  private func triggerEffect(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let intensity = args["intensity"] as? Double else {
      result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
      return
    }

    // Use UIImpactFeedbackGenerator for haptic feedback
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    feedbackGenerator.impactOccurred()
    result(nil)
  }

  private func isSupported(result: @escaping FlutterResult) {
    result(true)
  }

  private func dispose(result: @escaping FlutterResult) {
    result(nil)
  }
}


