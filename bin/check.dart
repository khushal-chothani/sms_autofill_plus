import 'dart:io';

void main() async {
  print('--- SMS OTP Autofill Project Validator ---');

  bool allOk = true;

  // 1. Check pubspec.yaml
  final pubspec = File('pubspec.yaml');
  if (await pubspec.exists()) {
    final content = await pubspec.readAsString();
    if (!content.contains('sms_otp_autofill')) {
      print('✗ sms_otp_autofill not found in pubspec.yaml');
      allOk = false;
    } else {
      print('✓ pubspec.yaml looks good');
    }
  }

  // 2. Check Android Manifest
  final manifest = File('android/app/src/main/AndroidManifest.xml');
  if (await manifest.exists()) {
    final content = await manifest.readAsString();
    if (content.contains('com.jaumard.smsautofill')) {
      print('✗ Legacy package name found in AndroidManifest.xml. Please update to com.shirsh94.smsotpautofill');
      allOk = false;
    } else {
      print('✓ AndroidManifest.xml looks good');
    }
  }

  // 3. Check for iOS oneTimeCode hint
  final iosFiles = Directory('lib').listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  bool foundHint = false;
  for (var file in iosFiles) {
    if ((await file.readAsString()).contains('AutofillHints.oneTimeCode')) {
      foundHint = true;
      break;
    }
  }
  if (!foundHint) {
    print('! Warning: No AutofillHints.oneTimeCode found in your Dart code. iOS autofill might not work.');
  } else {
    print('✓ Found AutofillHints.oneTimeCode');
  }

  if (allOk) {
    print('\nEverything looks good! If you still have issues, check TROUBLESHOOTING.md');
  } else {
    print('\nSome issues were found. Please fix them for the plugin to work correctly.');
  }
}
