import 'dart:async';
import 'dart:convert';
import 'package:chatter_bridge/screens/tabs/bookmark_tab.dart';
import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WritePage extends StatefulWidget {
  const WritePage({super.key});

  @override
  State<WritePage> createState() => _WritePageState();
}

class _WritePageState extends State<WritePage> {
  final TextEditingController inputController = TextEditingController();
  String detectedLangName = 'Detecting...';
  String selectedOutputLang = 'Hindi';
  String translatedText = '';
  bool isTranslating = false;
  bool isBookmarked = false;
  Timer? _debounce;
  final translator = GoogleTranslator();
  final FlutterTts flutterTts = FlutterTts();

  final Map<String, String> langCode = {
    'Afrikaans': 'af',
    'Arabic': 'ar',
    'Bengali': 'bn',
    'Chinese (Simplified)': 'zh-cn',
    'Chinese (Traditional)': 'zh-tw',
    'Dutch': 'nl',
    'English': 'en',
    'French': 'fr',
    'German': 'de',
    'Greek': 'el',
    'Gujarati': 'gu',
    'Hebrew': 'iw',
    'Hindi': 'hi',
    'Italian': 'it',
    'Japanese': 'ja',
    'Kannada': 'kn',
    'Korean': 'ko',
    'Malayalam': 'ml',
    'Marathi': 'mr',
    'Nepali': 'ne',
    'Portuguese': 'pt',
    'Punjabi': 'pa',
    'Russian': 'ru',
    'Spanish': 'es',
    'Swahili': 'sw',
    'Tamil': 'ta',
    'Telugu': 'te',
    'Thai': 'th',
    'Turkish': 'tr',
    'Urdu': 'ur',
    'Vietnamese': 'vi',
  };

  String _getLanguageName(String code) {
    return langCode.entries
        .firstWhere(
          (entry) => entry.value == code,
          orElse: () => const MapEntry('Unknown', ''),
        )
        .key;
  }

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

    setState(() {
      isTranslating = true;
      isBookmarked = false;
    });

    try {
      final translated = await translator.translate(
        inputText,
        to: langCode[selectedOutputLang]!,
      );

      setState(() {
        translatedText = translated.text;
        detectedLangName = _getLanguageName(translated.sourceLanguage.code);
      });

      await _checkIfBookmarked(inputText, translated.text);
    } catch (e) {
      setState(() {
        translatedText = 'Translation failed: $e';
        detectedLangName = 'Unknown';
      });
    } finally {
      setState(() {
        isTranslating = false;
      });
    }
  }

  Future<void> _speak(String text, String langCodeValue) async {
    if (text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No text to speak')));
      return;
    }

    try {
      // Initialize TTS
      await flutterTts.setVolume(1.0);
      await flutterTts.setPitch(1.0);
      await flutterTts.setSpeechRate(0.5);

      // Map language codes to TTS-compatible codes
      Map<String, String> ttsLanguageCodes = {
        'hi': 'hi-IN',
        'en': 'en-US',
        'es': 'es-ES',
        'fr': 'fr-FR',
        'de': 'de-DE',
        'it': 'it-IT',
        'ja': 'ja-JP',
        'ko': 'ko-KR',
        'ru': 'ru-RU',
        'zh-cn': 'zh-CN',
        'zh-tw': 'zh-TW',
        'ar': 'ar-SA',
        'bn': 'bn-IN',
        'nl': 'nl-NL',
        'el': 'el-GR',
        'gu': 'gu-IN',
        'iw': 'he-IL', // Hebrew
        'kn': 'kn-IN',
        'ml': 'ml-IN',
        'mr': 'mr-IN',
        'ne': 'ne-NP',
        'pt': 'pt-BR',
        'pa': 'pa-IN',
        'sw': 'sw-KE',
        'ta': 'ta-IN',
        'te': 'te-IN',
        'th': 'th-TH',
        'tr': 'tr-TR',
        'ur': 'ur-PK',
        'vi': 'vi-VN',
      };

      // Get selected language code or fallback to English
      String ttsLangCode = ttsLanguageCodes[langCodeValue] ?? 'en-US';

      // Check available languages
      List<dynamic> availableLanguages = await flutterTts.getLanguages;
      debugPrint('Available TTS languages: $availableLanguages');

      // Check if selected language is available, otherwise use English
      if (availableLanguages.contains(ttsLangCode)) {
        await flutterTts.setLanguage(ttsLangCode);
        debugPrint('Using language: $ttsLangCode');
      } else {
        // Try to find a similar language by prefix
        String prefix = ttsLangCode.split('-')[0];
        String? similarLanguage = availableLanguages.cast<String>().firstWhere(
          (lang) => lang.startsWith(prefix),
          orElse: () => 'en-US',
        );

        await flutterTts.setLanguage(similarLanguage);
        debugPrint('Using similar language: $similarLanguage');
      }

      // Add completion listener
      flutterTts.setCompletionHandler(() {
        debugPrint('TTS completed');
      });

      // Add error listener
      flutterTts.setErrorHandler((error) {
        debugPrint('TTS error: $error');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('TTS error: $error')));
      });

      // Speak the text
      var result = await flutterTts.speak(text);
      debugPrint('TTS result: $result');
      if (!mounted) return;
      if (result != 1) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to start speech')));
      }
    } catch (e) {
      debugPrint('TTS exception: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('TTS error: $e')));
    }
  }

  Future<void> _addToBookmarks(String original, String translated) async {
    await BookmarkTabState.addBookmark(original, translated);
    setState(() => isBookmarked = true);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Bookmark added!')));
  }

  Future<void> _checkIfBookmarked(String original, String translated) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> bookmarks = prefs.getStringList('bookmarks') ?? [];
    final checkBookmark = jsonEncode({
      'original': original,
      'translated': translated,
    });
    setState(() {
      isBookmarked = bookmarks.contains(checkBookmark);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildInputBox(
          controller: inputController,
          detectedLang: detectedLangName,
        ),
        const SizedBox(height: 16),
        _buildOutputBox(
          label: selectedOutputLang,
          text: translatedText,
          isLoading: isTranslating,
          dropdownItems: langCode.keys.toList(),
          onLanguageChanged: (val) {
            setState(() => selectedOutputLang = val!);
            _translateText();
          },
        ),
      ],
    );
  }

  Widget _buildInputBox({
    required TextEditingController controller,
    required String detectedLang,
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.language, size: 16),
                const SizedBox(width: 6),
                Text(
                  "Detected: $detectedLang",
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
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
    required bool isLoading,
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
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Theme(
                data: Theme.of(context).copyWith(
                  canvasColor: Colors.white,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.amber[100],
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: label,
                      isDense: true,

                      icon: const Icon(Icons.arrow_drop_down, size: 20),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                      ),
                      dropdownColor: Colors.white,
                      menuMaxHeight: 300,
                      borderRadius: BorderRadius.circular(12),
                      items:
                          dropdownItems
                              .map(
                                (lang) => DropdownMenuItem(
                                  value: lang,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: Text(lang),
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: onLanguageChanged,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child:
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            text,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.volume_up),
                  onPressed:
                      () =>
                          _speak(translatedText, langCode[selectedOutputLang]!),
                ),
                IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: isBookmarked ? Colors.amber[800] : null,
                  ),
                  onPressed: () => _addToBookmarks(inputController.text, text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
