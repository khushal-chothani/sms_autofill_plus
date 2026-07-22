import Cocoa
import FlutterMacOS

public class SmsOtpAutoFillPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "sms_autofill_plus", binaryMessenger: registrar.messenger)
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
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
