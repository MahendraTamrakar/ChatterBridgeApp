import 'package:chatter_bridge/screens/login_screen.dart';
import 'package:chatter_bridge/screens/main_ui.dart';
import 'package:chatter_bridge/screens/register_screen.dart';
import 'package:chatter_bridge/screens/welcome_screen.dart';
import 'package:chatter_bridge/utilities/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MaterialApp(
      title: "Chatter Bridge",
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),

      routes: {
        welcomePageRoute: (context) => const WelcomePage(),
        registerPageRoute: (context) => const RegisterScreen(),
        loginPageRoute: (context) => const LoginScreen(),
        homePageRoute: (context) => const HomeScreen(),
      },
    ),
  );
}
