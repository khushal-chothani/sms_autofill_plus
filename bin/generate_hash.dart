import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

void main(List<String> args) async {
  print('--- SMS OTP Autofill Hash Generator ---');

  String? packageName;
  String? keystorePath;
  String keystorePassword = 'android';
  String alias = 'androiddebugkey';

  // 1. Try to find package name from android/app/build.gradle
  try {
    final buildGradle = File('android/app/build.gradle');
    if (await buildGradle.exists()) {
      final content = await buildGradle.readAsString();
      final match = RegExp(r'applicationId\s+"([^"]+)"').firstMatch(content) ??
                    RegExp(r"applicationId\s+'([^']+)'").firstMatch(content);
      if (match != null) {
        packageName = match.group(1);
        print('Found package name: $packageName');
      }
    }
  } catch (_) {}

  if (packageName == null) {
    stdout.write('Enter your Android package name (e.g., com.example.app): ');
    packageName = stdin.readLineSync();
  }

  if (packageName == null || packageName.isEmpty) {
    print('Error: Package name is required.');
    exit(1);
  }

  // 2. Try to find debug keystore
  final home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
  if (home != null) {
    final debugKeystore = File('$home/.android/debug.keystore');
    if (await debugKeystore.exists()) {
      keystorePath = debugKeystore.path;
      print('Found debug keystore at: $keystorePath');
    }
  }

  print('\nThis tool will generate the 11-character hash for your Android app.');
  print('By default, it uses the debug keystore.');
  
  stdout.write('Use debug keystore? (y/n): ');
  final useDebug = stdin.readLineSync()?.toLowerCase() ?? 'y';

  if (useDebug != 'y') {
    stdout.write('Enter path to your keystore: ');
    keystorePath = stdin.readLineSync();
    stdout.write('Enter keystore password: ');
    keystorePassword = stdin.readLineSync() ?? '';
    stdout.write('Enter key alias: ');
    alias = stdin.readLineSync() ?? '';
  }

  if (keystorePath == null || !File(keystorePath).existsSync()) {
    print('Error: Keystore file not found.');
    exit(1);
  }

  try {
    // 3. Extract certificate using keytool
    final result = await Process.run('keytool', [
      '-exportcert',
      '-alias', alias,
      '-keystore', keystorePath,
      '-storepass', keystorePassword,
    ]);

    if (result.exitCode != 0) {
      print('Error running keytool: ${result.stderr}');
      exit(1);
    }

    final List<int> certBytes = result.stdout as List<int>;
    // The signature string in Android is the hex representation of the cert bytes
    final String signatureHex = certBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join('');

    final String appInfo = '$packageName $signatureHex';
    
    // 4. Calculate hash
    final bytes = utf8.encode(appInfo);
    final digest = sha256.convert(bytes);
    
    // Google's specific base64 encoding (truncated to 9 bytes then first 11 chars)
    final truncatedHash = digest.bytes.sublist(0, 9);
    final base64Hash = base64Encode(truncatedHash);
    final finalHash = base64Hash.substring(0, 11);

    print('\n----------------------------------------');
    print('Your SMS OTP Hash: $finalHash');
    print('----------------------------------------');
    print('\nExample SMS Template:');
    print('<#> Your verification code is 123456');
    print('$finalHash');
    print('----------------------------------------');

  } catch (e) {
    print('Error generating hash: $e');
    print('Ensure "keytool" is in your PATH.');
  }
}
