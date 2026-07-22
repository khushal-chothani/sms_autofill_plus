#ifndef FLUTTER_PLUGIN_SMS_OTP_AUTOFILL_PLUGIN_H_
#define FLUTTER_PLUGIN_SMS_OTP_AUTOFILL_PLUGIN_H_

#include <flutter_plugin_registrar.h>

#ifdef FLUTTER_PLUGIN_EXPORT
#define FLUTTER_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FLUTTER_PLUGIN_EXPORT
#endif

#if defined(__cplusplus)
extern "C" {
#endif

FLUTTER_PLUGIN_EXPORT void SmsOtpAutoFillPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar);

#if defined(__cplusplus)
}
#endif

#endif  // FLUTTER_PLUGIN_SMS_OTP_AUTOFILL_PLUGIN_H_
