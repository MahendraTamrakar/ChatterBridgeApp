import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelloLanguages extends StatefulWidget {
  const HelloLanguages({super.key});

  @override
  State<HelloLanguages> createState() => _HelloLanguagesState();
}

class _HelloLanguagesState extends State<HelloLanguages> {
  final List<String> greetings = [
    'Hello!', // English
    'नमस्ते!', // Hindi
    'Hola!', // Spanish
    'Hallo!', // German
    'Bonjour!', // French
    'Ciao!', // Italian
    'こんにちは!', // Japanese
    '안녕하세요!', // Korean
    'Olá!', // Portuguese
  ];

  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % greetings.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        greetings[_currentIndex],
        style: GoogleFonts.pacifico(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 54, 55, 56),
        ),
      ),
    );
  }
}
