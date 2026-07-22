# sms_autofill_plus

[![pub package](https://img.shields.io/pub/v/sms_autofill_plus.svg)](https://pub.dartlang.org/packages/sms_autofill_plus)
[![license](https://img.shields.io/github/license/shirsh94/sms_autofill_plus.svg)](https://github.com/shirsh94/sms_autofill_plus/blob/main/LICENSE)
![platform](https://img.shields.io/badge/platform-android%20%7C%20ios%20%7C%20web-blue.svg)
[![Stars](https://img.shields.io/github/stars/shirsh94/sms_autofill_plus.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/shirsh94/sms_autofill_plus)

A modern, comprehensive SMS OTP Autofill solution for Flutter. It provides a unified API to handle OTP retrieval across Android, iOS, and Web, featuring Material 3 UI components and deep integration with services like Firebase.

---

## 🚀 Features

- **Unified API**: Single stream-based API for all platforms.
- **Android Support**:
  - **SMS Retriever API**: Fully automatic code retrieval (no user interaction).
  - **User Consent API**: One-tap approval for code retrieval.
  - **Phone Hint API**: Quickly pick the user's phone number.
- **Web Support**: **WebOTP API** support with WASM compatibility (using `package:web`).
- **Modern UI Components**:
  - `OtpField`: Highly customizable, Material 3 & Cupertino inspired.
  - `FirebaseOtpField`: Zero-boilerplate integration with Firebase Phone Auth.
  - `PhoneFieldHint`: Built-in phone number selector.
- **Advanced Logic**:
  - `OtpSession`: Automatic lifecycle management (listening, timeouts, cleanup).
  - `OtpParser`: Flexible regex-based extraction of codes from SMS.
  - `SmsOtpDiagnostics`: Detailed debug info for Android environment.
- **Zero Configuration**: No SMS permissions required on Android.

---

## 📦 Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  sms_autofill_plus: ^1.0.0
```

---

## 📖 Usage

### 1. High-Level Logic API (`SmsOtp`)

The simplest way to start listening for an OTP:

```dart
final smsOtp = SmsOtp();

// Start listening before your backend sends the SMS
await smsOtp.startListening(
  strategy: AutofillStrategy.auto, // Tries Retriever, falls back to Consent
);

smsOtp.stream.listen((result) {
  if (result.isSuccess) {
    print("OTP Received: ${result.code}");
  } else {
    print("Error: ${result.failure}");
  }
});

// Don't forget to dispose
smsOtp.dispose();
```

### 2. Modern UI Component (`OtpField`)

A ready-to-use OTP input field that handles focus, keyboard, and autofill automatically.

```dart
OtpField(
  length: 6,
  theme: OtpTheme.material3(context),
  status: OtpStatus.idle, // loading, success, error
  onCompleted: (code) {
    print("Entered Code: $code");
  },
)
```

---

## 🎨 UI Customization

### Spacing and Detailed Styling
You can easily adjust the gap, width, colors, and behavior using `copyWith` or the main constructor:

```dart
OtpField(
  length: 4,
  obscureText: true,
  obscuringCharacter: '*',
  keyboardType: TextInputType.number,
  theme: OtpTheme.material3(context).copyWith(
    gap: 20,
    width: 60,
    activeBorderColor: Colors.deepPurple,
    borderRadius: BorderRadius.circular(4),
    filledBackgroundColor: Colors.grey.withValues(alpha: 0.1),
    disabledBackgroundColor: Colors.black12,
  ),
)
```

---

## 🔧 Platform Configuration

### Android SMS Retriever API
To enable fully automatic, zero-tap OTP retrieval, your SMS must follow these Google-mandated rules:

1.  **Length**: Be no longer than 140 bytes.
2.  **OTP**: Contain a one-time code.
3.  **Hash String**: End with an **11-character hash string** that identifies your app.

#### The App Signature Process
The hash string is unique to your app's package name and the certificate used to sign it (debug or release).

1.  **Get the Hash**: Call the helper in your app during development:
    ```dart
    String signature = await SmsAutoFillPlus().getAppSignature;
    print("Your Hash: $signature");
    ```
2.  **Server Integration**: Send this 11-character string to your backend.
3.  **SMS Template**: Format your SMS like this:
    ```
    Your verification code is 123456
    FA+9qCX9VSu
    ```
    *Note: The hash must be at the very end.*

---

## 🔍 Diagnostics & Debugging

### Simulating SMS (Mocking)
You can test your implementation without sending real SMS messages:

```dart
await SmsAutoFillPlus().simulateMessage("Your code is 1234\nFA+9qCX9VSu");
```

### Diagnostics Tool
If autofill isn't working as expected on Android, use this to check the environment:

```dart
final report = await SmsOtp().diagnostics;
print(report);
```

---

## 📜 License
MIT
