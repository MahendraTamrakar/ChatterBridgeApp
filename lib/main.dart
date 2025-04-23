import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chatter_bridge/screens/login_screen.dart';
import 'package:chatter_bridge/screens/main_ui.dart';
import 'package:chatter_bridge/screens/register_screen.dart';
import 'package:chatter_bridge/screens/welcome_screen.dart';
import 'package:chatter_bridge/utilities/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final prefs = await SharedPreferences.getInstance();
  final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
  final user = FirebaseAuth.instance.currentUser;

  Widget initialScreen;

  if (isFirstLaunch) {
    await prefs.setBool('isFirstLaunch', false);
    initialScreen = const WelcomePage();
  } else if (user != null) {
    initialScreen = const HomeScreen();
  } else {
    initialScreen = const LoginScreen();
  }

  runApp(MyApp(initialScreen: initialScreen));
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;
  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Chatter Bridge",
      debugShowCheckedModeBanner: false,
      home: initialScreen,
      routes: {
        welcomePageRoute: (context) => const WelcomePage(),
        registerPageRoute: (context) => const RegisterScreen(),
        loginPageRoute: (context) => const LoginScreen(),
        homePageRoute: (context) => const HomeScreen(),
      },
    );
  }
}
