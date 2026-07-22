import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:web/web.dart' as web;
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:flutter/services.dart';

class SmsAutoFillPlusWeb {
  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel(
      'sms_autofill_plus',
      const StandardMethodCodec(),
      registrar,
    );

    final pluginInstance = SmsAutoFillPlusWeb();
    channel.setMethodCallHandler(pluginInstance.handleMethodCall);
  }

  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'listenForCode':
        return _listenForCode();
      case 'requestPhoneHint':
      case 'unregisterListener':
        return null;
      case 'getAppSignature':
        return '';
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: 'sms_autofill_plus for web doesn\'t implement \'${call.method}\'',
        );
    }
  }

  Future<void> _listenForCode() async {
    try {
      final credentials = web.window.navigator.credentials;
      
      // Prepare the OTP options for the WebOTP API
      final otpOptions = JSObject();
      otpOptions.setProperty('transport'.toJS, <JSString>['sms'.toJS].toJS);
      
      final options = web.CredentialRequestOptions(
        otp: otpOptions as web.OTPCredentialRequestOptions,
      );

      final promise = credentials.get(options);
      final credential = await promise.toDart;
      
      if (credential != null) {
        // The credential returned by WebOTP API has a 'code' property
        final jsCredential = credential as JSObject;
        final codeValue = jsCredential.getProperty('code'.toJS);
        
        if (codeValue.isDefinedAndNotNull) {
          final code = (codeValue as JSString).toDart;
          const MethodChannel('sms_autofill_plus').invokeMethod('smscode', code);
        }
      }
    } catch (e) {
      // WebOTP might not be supported or user cancelled
    }
  }
}
