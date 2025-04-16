import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';

class BookmarkTab extends StatefulWidget {
  const BookmarkTab({super.key});

  @override
  State<BookmarkTab> createState() => _BookmarkTabState();
}

class _BookmarkTabState extends State<BookmarkTab> {
  final FlutterTts flutterTts = FlutterTts();
  List<Map<String, String>> _bookmarks = [];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> bookmarkStrings = prefs.getStringList('bookmarks') ?? [];
    setState(() {
      _bookmarks =
          bookmarkStrings
              .map((b) => Map<String, String>.from(jsonDecode(b)))
              .toList();
    });
  }

  Future<void> _deleteBookmark(int index) async {
    final prefs = await SharedPreferences.getInstance();
    _bookmarks.removeAt(index);
    final updatedList = _bookmarks.map((b) => jsonEncode(b)).toList();
    await prefs.setStringList('bookmarks', updatedList);
    setState(() {});
  }

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("en");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Text copied to clipboard')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Bookmarks",
          style: GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.amber[200],
      ),
      body:
          _bookmarks.isEmpty
              ? const Center(child: Text("No bookmarks yet."))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _bookmarks.length,
                itemBuilder: (context, index) {
                  final item = _bookmarks[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(
                        item['original'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(item['translated'] ?? ''),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'speak') {
                            _speak(item['translated'] ?? '');
                          } else if (value == 'copy') {
                            _copyToClipboard(item['translated'] ?? '');
                          } else if (value == 'delete') {
                            _deleteBookmark(index);
                          }
                        },
                        itemBuilder:
                            (context) => [
                              const PopupMenuItem(
                                value: 'speak',
                                child: Text('Speak'),
                              ),
                              const PopupMenuItem(
                                value: 'copy',
                                child: Text('Copy'),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
