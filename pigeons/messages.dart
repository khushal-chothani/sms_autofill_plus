import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  dartOptions: DartOptions(),
  cppOptions: CppOptions(namespace: 'sms_autofill_plus'),
  cppHeaderOut: 'windows/messages.g.h',
  cppSourceOut: 'windows/messages.g.cpp',
  kotlinOut: 'android/src/main/kotlin/com/shirsh94/smsotpautofill/Messages.g.kt',
  kotlinOptions: KotlinOptions(),
  swiftOut: 'ios/sms_autofill_plus/Sources/sms_autofill_plus/Messages.g.swift',
  swiftOptions: SwiftOptions(),
  objcHeaderOut: 'ios/sms_autofill_plus/Sources/sms_autofill_plus/include/sms_autofill_plus/Messages.g.h',
  objcSourceOut: 'ios/sms_autofill_plus/Sources/sms_autofill_plus/Messages.g.m',
  objcOptions: ObjcOptions(
    headerIncludePath: './include/sms_autofill_plus/Messages.g.h',
  ),
))

enum AutofillStrategy {
  auto,
  retriever,
  consent,
}

class DiagnosticReport {
  bool? isPlayServicesAvailable;
  bool? isRetrieverAvailable;
  bool? isUserConsentAvailable;
  String? appSignature;
  bool? isReceiverRegistered;
}

@HostApi()
abstract class SmsOtpAutoFillApi {
  @async
  String? requestPhoneHint();

  void listenForCode(String regex, AutofillStrategy strategy, String? senderPhoneNumber);

  void unregisterListener();

  String getAppSignature();

  DiagnosticReport getDiagnostics();
}

@FlutterApi()
abstract class SmsOtpAutoFillFlutterApi {
  void onSmsReceived(String code);
  void onTimeout();
  void onError(String errorCode);
}
