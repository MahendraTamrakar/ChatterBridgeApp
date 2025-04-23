import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:translator/translator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScanTab extends StatefulWidget {
  const ScanTab({super.key});

  @override
  State<ScanTab> createState() => _ScanTabState();
}

class _ScanTabState extends State<ScanTab> {
  String scannedText = "No text found yet.";
  String translatedText = "";
  String selectedOutputLang = 'English';
  File? imageFile;

  final translator = GoogleTranslator();

  final Map<String, String> langCode = {
    'English': 'en',
    'Hindi': 'hi',
    'Spanish': 'es',
    'French': 'fr',
    'German': 'de',
    'Italian': 'it',
    'Russian': 'ru',
    'Arabic': 'ar',
    'Chinese': 'zh-cn',
    'Japanese': 'ja',
    'Portuguese': 'pt',
    'Korean': 'ko',
    'Urdu': 'ur',
    'Bengali': 'bn',
    'Turkish': 'tr',
  };

  @override
  void initState() {
    super.initState();
    _pickImageFromCamera();
  }

  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      setState(() {
        imageFile = file;
        scannedText = "Scanning...";
        translatedText = "";
      });
      await _scanAndTranslateText(file);
    }
  }

  Future<void> _scanAndTranslateText(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText = await textRecognizer.processImage(
      inputImage,
    );

    final extracted = recognizedText.text.trim();

    setState(() {
      scannedText = extracted.isNotEmpty ? extracted : "No text found.";
    });

    if (extracted.isNotEmpty) {
      final translated = await translator.translate(
        extracted,
        from: 'auto', // Auto-detect the scanned text language
        to: langCode[selectedOutputLang]!,
      );
      setState(() {
        translatedText = translated.text;
      });
    }

    textRecognizer.close();
  }

  Future<void> _bookmarkTranslation() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> existing = prefs.getStringList('bookmarks') ?? [];

    final entry = jsonEncode({
      'original': scannedText,
      'translated': translatedText,
    });

    existing.add(entry);
    await prefs.setStringList('bookmarks', existing);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Bookmark added')));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 5),
        if (imageFile != null) Image.file(imageFile!, height: 200),
        const SizedBox(height: 20),
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: 270,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                child: Theme(
                  data: Theme.of(context).copyWith(
                    canvasColor: Colors.white,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.amber[100],
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedOutputLang,
                        isDense: true,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        underline: const SizedBox(),
                        items:
                            langCode.keys
                                .map(
                                  (lang) => DropdownMenuItem(
                                    value: lang,
                                    child: Text(lang),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => selectedOutputLang = value);
                            _scanAndTranslateText(imageFile!);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40, bottom: 40),
                child: SingleChildScrollView(
                  child: Text(
                    translatedText.isEmpty
                        ? 'Translated text will appear here...'
                        : translatedText,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.bookmark_border),
                  onPressed: _bookmarkTranslation,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
