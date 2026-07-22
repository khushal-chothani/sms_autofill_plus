import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'sms_autofill_plus_method_channel.dart';
import 'sms_autofill_plus.dart';

abstract class SmsAutoFillPlusPlatform extends PlatformInterface {
  SmsAutoFillPlusPlatform() : super(token: _token);

  static final Object _token = Object();

  static SmsAutoFillPlusPlatform _instance = MethodChannelSmsAutoFillPlus();

  static SmsAutoFillPlusPlatform get instance => _instance;

  static set instance(SmsAutoFillPlusPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Stream<OtpResult> get results;

  Future<String?> requestPhoneHint();

  Future<void> listenForCode({
    OtpParser? parser,
    AutofillStrategy strategy = AutofillStrategy.auto,
    String? senderPhoneNumber,
  });

  Future<void> unregisterListener();

  Future<String> getAppSignature();

  Future<Map<String, dynamic>?> getDiagnostics();

  Future<void> simulateMessage(String message);
}
