#include "include/sms_otp_autofill/sms_otp_autofill_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <map>
#include <memory>
#include <sstream>

namespace {

class SmsOtpAutoFillPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  SmsOtpAutoFillPlugin();

  virtual ~SmsOtpAutoFillPlugin();

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

// static
void SmsOtpAutoFillPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "sms_autofill_plus",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<SmsOtpAutoFillPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

SmsOtpAutoFillPlugin::SmsOtpAutoFillPlugin() {}

SmsOtpAutoFillPlugin::~SmsOtpAutoFillPlugin() {}

void SmsOtpAutoFillPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name().compare("getAppSignature") == 0) {
    result->Success(flutter::EncodableValue(""));
  } else if (method_call.method_name().compare("listenForCode") == 0) {
    result->Success();
  } else if (method_call.method_name().compare("requestPhoneHint") == 0) {
    result->Success();
  } else if (method_call.method_name().compare("unregisterListener") == 0) {
    result->Success();
  } else {
    result->NotImplemented();
  }
}

}  // namespace

void SmsOtpAutoFillPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  SmsOtpAutoFillPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
