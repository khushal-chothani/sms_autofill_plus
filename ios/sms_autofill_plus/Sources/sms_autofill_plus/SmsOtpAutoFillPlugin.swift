import Flutter
import UIKit

/// iOS stub — SMS Retriever / User Consent APIs are Android-only.
/// Dart still talks over MethodChannel `sms_autofill_plus` (same as Android/macOS).
/// `Messages.g.swift` is the Pigeon Swift surface for a future HostApi migration.
public class SmsOtpAutoFillPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "sms_autofill_plus",
      binaryMessenger: registrar.messenger()
    )
    let instance = SmsOtpAutoFillPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "requestPhoneHint":
      result(nil)
    case "listenForCode":
      result(nil)
    case "unregisterListener":
      result(nil)
    case "getAppSignature":
      result("")
    case "getDiagnostics":
      result([
        "isPlayServicesAvailable": false,
        "isRetrieverAvailable": false,
        "isUserConsentAvailable": false,
        "appSignature": "",
        "isReceiverRegistered": false,
      ])
    case "simulateMessage":
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
