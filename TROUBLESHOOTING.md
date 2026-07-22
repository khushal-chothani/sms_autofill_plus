# Troubleshooting Guide

If SMS autofill is not working as expected, follow this checklist to identify and fix common issues.

## 1. Run Diagnostics
The first step should always be running the built-in diagnostics on an actual device.

```dart
final diagnostics = await SmsOtp().diagnostics;
print(diagnostics);
```

## 2. Common Failure Modes

### ❌ "App Signature Valid: ✗"
**Cause:** The 11-character hash in your SMS doesn't match your app's signature.
**Fix:**
- Run `flutter pub run sms_otp_autofill:generate_hash` to get the correct hash.
- Ensure you are using the correct hash for the correct build variant (Debug vs Release). Play Store App Signing changes the signature!

### ❌ SMS Received but not extracted
**Cause:** The SMS format doesn't match the regex or the `OtpParser`.
**Fix:**
- Use `OtpParser.auto()` for standard formats.
- For custom formats, test your regex using a tool like [RegExr](https://regexr.com/).
- Ensure the SMS starts with `<#>` or contains the app signature at the end (Android Retriever API).

### ❌ "Play Services: ✗"
**Cause:** Google Play Services are missing or outdated on the device.
**Fix:** SMS Retriever API requires Play Services. Use `AutofillStrategy.consent` as a fallback or prompt the user to update Play Services.

### ❌ iOS Autofill not showing
**Cause:** `AutofillHints.oneTimeCode` missing or `textContentType` not set correctly.
**Fix:** `OtpField` handles this automatically. If using a custom field, ensure `autofillHints: [AutofillHints.oneTimeCode]` is present.

## 3. Android Manifest Requirements
Ensure your `AndroidManifest.xml` has the correct package name. The plugin handles receiver registration automatically, so you don't need to add `<receiver>` tags manually.

## 4. SMS Format Validator
Your SMS must follow these rules for the Retriever API:
1. Start with `<#>` (Optional but recommended).
2. End with the 11-character app hash.
3. Be no longer than 140 bytes.

**Valid Example:**
```
<#> Your verification code is 123456
FA+9qCX9VSu
```
