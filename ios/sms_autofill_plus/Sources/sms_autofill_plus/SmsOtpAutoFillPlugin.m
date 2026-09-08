#import "./include/sms_autofill_plus/SmsOtpAutoFillPlugin.h"

@implementation SmsOtpAutoFillPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"sms_autofill_plus"
            binaryMessenger:[registrar messenger]];
  SmsOtpAutoFillPlugin* instance = [[SmsOtpAutoFillPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"requestPhoneHint" isEqualToString:call.method]) {
      result(nil);
  } else if ([@"listenForCode" isEqualToString:call.method]) {
      result(nil);
  } else if ([@"unregisterListener" isEqualToString:call.method]) {
      result(nil);
  } else if ([@"getAppSignature" isEqualToString:call.method]) {
      result(@"");
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
