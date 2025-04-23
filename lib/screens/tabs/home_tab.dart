// ignore_for_file: unused_element, unreachable_switch_default

import 'dart:async';
import 'package:chatter_bridge/screens/tabs/pages/record_page.dart';
import 'package:chatter_bridge/screens/tabs/pages/scan_page.dart';
import 'package:chatter_bridge/screens/tabs/pages/write_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:translator/translator.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

enum SelectedTab { write, record, scan }

class _HomeTabState extends State<HomeTab> {
  SelectedTab _selectedTab = SelectedTab.write;

  final TextEditingController inputController = TextEditingController();
  String selectedInputLang = 'English';
  String selectedOutputLang = 'Italian';
  String translatedText = '';

  final translator = GoogleTranslator();
  Timer? _debounce;

  final Map<String, String> langCode = {
    'English': 'en',
    'Hindi': 'hi',
    'Italian': 'it',
  };

  @override
  void initState() {
    super.initState();
    inputController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    inputController.removeListener(_onInputChanged);
    inputController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onInputChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _translateText();
    });
  }

  Future<void> _translateText() async {
    final inputText = inputController.text.trim();
    if (inputText.isEmpty) return;

    final translated = await translator.translate(
      inputText,
      from: langCode[selectedInputLang]!,
      to: langCode[selectedOutputLang]!,
    );

    setState(() {
      translatedText = translated.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Chatter Bridge",
          style: GoogleFonts.pacifico(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.amber[200],
      ),
      backgroundColor: Colors.amber[200],
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18.0),
                child: _buildCurrentTabContent(),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(bottom: 50.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildBottomBoxButton(Icons.edit, "Write", SelectedTab.write),
                  _buildBottomBoxButton(
                    Icons.mic,
                    "Record",
                    SelectedTab.record,
                  ),
                  _buildBottomBoxButton(
                    Icons.document_scanner,
                    "Scan",
                    SelectedTab.scan,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentTabContent() {
    switch (_selectedTab) {
      case SelectedTab.record:
        return const RecordTab();
      case SelectedTab.scan:
        return const ScanTab();
      case SelectedTab.write:
      default:
        return const WritePage();
    }
  }

  Widget _buildBottomBoxButton(IconData icon, String label, SelectedTab tab) {
    final bool isSelected = _selectedTab == tab;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = tab;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? const Color.fromARGB(255, 58, 58, 51)
                  : const Color.fromARGB(255, 123, 123, 104),
          borderRadius: BorderRadius.circular(12),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ]
                  : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTranslateBox({
    required String label,
    required TextEditingController controller,
    required List<String> dropdownItems,
    required bool isTop,
    required ValueChanged<String?> onLanguageChanged,
  }) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButton<String>(
            value: label,
            icon: const Icon(Icons.keyboard_arrow_down),
            underline: const SizedBox(),
            items:
                dropdownItems
                    .map(
                      (lang) =>
                          DropdownMenuItem(value: lang, child: Text(lang)),
                    )
                    .toList(),
            onChanged: onLanguageChanged,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: null,
              expands: true,
              decoration: const InputDecoration(
                hintText: 'Enter text...',
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutputBox({
    required String label,
    required String text,
    required List<String> dropdownItems,
    required ValueChanged<String?> onLanguageChanged,
  }) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButton<String>(
            value: label,
            icon: const Icon(Icons.keyboard_arrow_down),
            underline: const SizedBox(),
            items:
                dropdownItems
                    .map(
                      (lang) =>
                          DropdownMenuItem(value: lang, child: Text(lang)),
                    )
                    .toList(),
            onChanged: onLanguageChanged,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
