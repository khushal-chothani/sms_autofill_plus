import 'package:flutter/material.dart';
import 'package:sms_autofill_plus/sms_autofill_plus.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.light,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('OTP Autofill Plus Demo'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Standard', icon: Icon(Icons.password)),
              Tab(text: 'Firebase', icon: Icon(Icons.local_fire_department)),
              Tab(text: 'Phone Hint', icon: Icon(Icons.phone_android)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            StandardOtpDemo(),
            FirebaseOtpDemo(),
            PhoneHintDemo(),
          ],
        ),
      ),
    );
  }
}

/// --- Standard OTP Field Demo ---
class StandardOtpDemo extends StatefulWidget {
  const StandardOtpDemo({Key? key}) : super(key: key);

  @override
  State<StandardOtpDemo> createState() => _StandardOtpDemoState();
}

class _StandardOtpDemoState extends State<StandardOtpDemo> {
  final SmsOtp _smsOtp = SmsOtp();
  final TextEditingController _controller = TextEditingController();
  OtpStatus _status = OtpStatus.idle;
  String _signature = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadSignature();
    _smsOtp.stream.listen((result) {
      if (result.isSuccess) {
        setState(() {
          _status = OtpStatus.success;
          _controller.text = result.code!;
        });
      } else if (result.failure != null) {
        setState(() => _status = OtpStatus.error);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: ${result.failure}")),
        );
      }
    });
  }

  Future<void> _loadSignature() async {
    final sig = await SmsAutoFillPlus().getAppSignature;
    setState(() => _signature = sig);
  }

  void _verifyCode(String code) {
    setState(() => _status = OtpStatus.loading);
    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _status = (code == "123456" || code == "1234") ? OtpStatus.success : OtpStatus.error;
        });
      }
    });
  }

  @override
  void dispose() {
    _smsOtp.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text("App Signature", style: Theme.of(context).textTheme.labelLarge),
                  SelectableText(_signature, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            "Enter Verification Code",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            "We've sent a code to your phone",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          OtpField(
            length: 6,
            controller: _controller,
            status: _status,
            theme: OtpTheme.material3(context).copyWith(
              gap: 12,
              activeBorderColor: Colors.deepPurple,
              activeBorderWidth: 2,
            ),
            onCompleted: _verifyCode,
            onChanged: (val) {
              if (_status != OtpStatus.idle) setState(() => _status = OtpStatus.idle);
            },
          ),
          const SizedBox(height: 24),
          Text(
            "Custom Style (Underline Builder)",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
          OtpField(
            length: 4,
            obscureText: true,
            theme: OtpTheme.material3(context).copyWith(
              width: 50,
              gap: 20,
              borderRadius: BorderRadius.circular(8),
              borderColor: Colors.blueGrey,
              activeBorderColor: Colors.deepPurple,
              filledBackgroundColor: Colors.deepPurple.withValues(alpha: 0.05),
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => _smsOtp.startListening(),
            child: const Text("Start SMS Listener"),
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: () async {
              await SmsAutoFillPlus().simulateMessage("Your code is 123456\n$_signature");
            },
            child: const Text("Simulate Success SMS"),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              _controller.clear();
              setState(() => _status = OtpStatus.idle);
            },
            child: const Text("Clear / Reset"),
          ),
        ],
      ),
    );
  }
}

/// --- Firebase Integration Demo ---
class FirebaseOtpDemo extends StatefulWidget {
  const FirebaseOtpDemo({Key? key}) : super(key: key);

  @override
  State<FirebaseOtpDemo> createState() => _FirebaseOtpDemoState();
}

class _FirebaseOtpDemoState extends State<FirebaseOtpDemo> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.local_fire_department, size: 64, color: Colors.orange),
          const SizedBox(height: 24),
          const Text(
            "Firebase Phone Auth Integration",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Zero-boilerplate wrapper for Firebase PhoneAuthProvider",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          FirebaseOtpField(
            onVerify: (code) async {
              // Mocking Firebase Auth behavior
              await Future.delayed(const Duration(seconds: 2));
              if (code == "123456") return "FirebaseUserObj";
              throw "Invalid Firebase SMS Code";
            },
            onVerified: (user) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Firebase Login Success!"), backgroundColor: Colors.green),
              );
            },
            onError: (e) {
               ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Firebase Error: $e"), backgroundColor: Colors.red),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// --- Phone Hint Demo ---
class PhoneHintDemo extends StatelessWidget {
  const PhoneHintDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Phone Number Selector",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Uses Android Smart Lock / Phone Hint API to quickly pick a phone number.",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          const PhoneFieldHint(
            decoration: InputDecoration(
              labelText: "Mobile Number",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
            ),
          ),
          const SizedBox(height: 24),
          const PhoneFormFieldHint(
             decoration: InputDecoration(
              labelText: "Secondary Number",
              border: UnderlineInputBorder(),
              hintText: "Click to see hint",
            ),
          ),
        ],
      ),
    );
  }
}
