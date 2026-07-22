import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'sms_autofill_plus.dart';

class MethodChannelSmsAutoFillPlus extends SmsAutoFillPlusPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('sms_autofill_plus');

  final StreamController<OtpResult> _resultsController = StreamController.broadcast();

  MethodChannelSmsAutoFillPlus() {
    methodChannel.setMethodCallHandler(_handleMethodCall);
  }

  @override
  Stream<OtpResult> get results => _resultsController.stream;

  Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'smscode':
        _resultsController.add(OtpResult.success(call.arguments as String));
        break;
      case 'timeout':
        _resultsController.add(OtpResult.timeout());
        break;
      case 'error':
        final String errorCode = call.arguments as String;
        switch (errorCode) {
          case 'PLAY_SERVICES_MISSING':
            _resultsController.add(OtpResult.playServicesMissing());
            break;
          case 'PERMISSION_DENIED':
            _resultsController.add(OtpResult.permissionDenied());
            break;
          case 'UNSUPPORTED_DEVICE':
            _resultsController.add(OtpResult.unsupportedDevice());
            break;
          default:
            _resultsController.add(OtpResult.unknown());
        }
        break;
    }
  }

  @override
  Future<String?> requestPhoneHint() async {
    return await methodChannel.invokeMethod<String>('requestPhoneHint');
  }

  @override
  Future<void> listenForCode({
    OtpParser? parser,
    AutofillStrategy strategy = AutofillStrategy.auto,
    String? senderPhoneNumber,
  }) async {
    final effectiveParser = parser ?? OtpParser.auto();
    await methodChannel.invokeMethod<void>(
      'listenForCode',
      <String, dynamic>{
        'smsCodeRegexPattern': effectiveParser.pattern,
        'strategy': strategy.toString().split('.').last,
        'senderPhoneNumber': senderPhoneNumber,
      },
    );
  }

  @override
  Future<void> unregisterListener() async {
    await methodChannel.invokeMethod<void>('unregisterListener');
  }

  @override
  Future<String> getAppSignature() async {
    final String? appSignature = await methodChannel.invokeMethod<String>('getAppSignature');
    return appSignature ?? '';
  }

  @override
  Future<Map<String, dynamic>?> getDiagnostics() async {
    final Map<dynamic, dynamic>? data = await methodChannel.invokeMethod<Map>('getDiagnostics');
    return data?.cast<String, dynamic>();
  }

  @override
  Future<void> simulateMessage(String message) async {
    await methodChannel.invokeMethod<void>('simulateMessage', {'message': message});
  }
}
