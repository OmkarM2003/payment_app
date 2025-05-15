import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:payment_app/firebase_options.dart';
import 'package:payment_app/helper/helper_fuction.dart';
import 'package:payment_app/view/home_page.dart';
import 'package:payment_app/view/auth/login_page.dart';

final _noScreenshot = NoScreenshot.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Block screenshots (for Android)
  bool result = await _noScreenshot.screenshotOff();
  debugPrint('Screenshot Off: $result');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> checkLoginStatus() async {
    return await HelperFunctions.getUserLoggedInStatus() ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return snapshot.data == true ? const HomePage() : const LoginPage();
          }
        },
      ),
    );
  }
}
