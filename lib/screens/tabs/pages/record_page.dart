import 'package:chatter_bridge/screens/tabs/bookmark_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:translator/translator.dart';
import 'dart:math';

class RecordTab extends StatefulWidget {
  const RecordTab({super.key});

  @override
  State<RecordTab> createState() => _RecordTabState();
}

class _RecordTabState extends State<RecordTab> with TickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  final translator = GoogleTranslator();
  final stt.SpeechToText _speech = stt.SpeechToText();

  String selectedOutputLang = 'English';
  final Map<String, String> langCode = {
    'English': 'en',
    'Hindi': 'hi',
    'Spanish': 'es',
    'French': 'fr',
    'German': 'de',
    'Chinese': 'zh-cn',
    'Japanese': 'ja',
    'Russian': 'ru',
    'Arabic': 'ar',
    'Portuguese': 'pt',
    'Korean': 'ko',
    'Italian': 'it',
    'Turkish': 'tr',
    'Bengali': 'bn',
    'Urdu': 'ur',
  };

  String translatedText = '';
  String recognizedText = '';
  bool isListening = false;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (val) async {
        setState(() => isListening = val == 'listening');
        if (isListening) {
          _animationController.repeat();
        } else {
          _animationController.stop();
          _animationController.reset();
        }
      },
      onError: (val) => debugPrint('Speech Error: $val'),
    );

    if (available) {
      _speech.listen(
        onResult: (val) async {
          if (val.hasConfidenceRating && val.confidence > 0) {
            setState(() => recognizedText = val.recognizedWords);
            final translated = await translator.translate(
              recognizedText,
              from: 'auto',
              to: langCode[selectedOutputLang]!,
            );
            setState(() => translatedText = translated.text);
          }
        },
      );
    }
  }

  Future<void> _speakText(String text) async {
    await flutterTts.setLanguage(langCode[selectedOutputLang]!);
    await flutterTts.speak(text);
  }

  void _bookmarkTranslation() async {
    if (translatedText.isNotEmpty && recognizedText.isNotEmpty) {
      await BookmarkTabState.addBookmark(recognizedText, translatedText);
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(const SnackBar(content: Text('Translation bookmarked!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: 250,
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
                        vertical: 3,
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
                          ? 'Translation will appear here...'
                          : translatedText,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.bookmark_border),
                        onPressed: _bookmarkTranslation,
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up),
                        onPressed: () => _speakText(translatedText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          if (isListening)
            SizedBox(
              height: 40,
              width: MediaQuery.of(context).size.width * 0.9,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: WaveformPainter(_animationController.value),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _startListening,
            child: CircleAvatar(
              radius: 35,
              backgroundColor: Colors.black,
              child: Icon(
                isListening ? Icons.mic_off : Icons.mic,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final double progress;
  WaveformPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.blueAccent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    final path = Path();
    for (double i = 0; i < size.width; i++) {
      double y =
          size.height / 2 +
          sin((i / size.width * 2 * pi * 2) + (progress * 2 * pi)) *
              size.height /
              4;
      if (i == 0) {
        path.moveTo(i, y);
      } else {
        path.lineTo(i, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
