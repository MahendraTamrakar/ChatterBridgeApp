import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookmarkTab extends StatefulWidget {
  const BookmarkTab({super.key});

  @override
  State<BookmarkTab> createState() => BookmarkTabState();
}

class BookmarkTabState extends State<BookmarkTab> {
  final FlutterTts flutterTts = FlutterTts();

  /// Static method to add a bookmark from anywhere
  static Future<void> addBookmark(String original, String translated) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('bookmarks')
        .doc(user.uid)
        .collection('items')
        .add({
          'original': original,
          'translated': translated,
          'timestamp': FieldValue.serverTimestamp(),
        });
  }

  /// Optional: check if a specific bookmark already exists
  static Future<bool> checkIfBookmarked(
    String original,
    String translated,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final snapshot =
        await FirebaseFirestore.instance
            .collection('bookmarks')
            .doc(user.uid)
            .collection('items')
            .where('original', isEqualTo: original)
            .where('translated', isEqualTo: translated)
            .get();

    return snapshot.docs.isNotEmpty;
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
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Bookmarks",
          style: GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.amber[200],
      ),
      backgroundColor: Colors.amber[200],
      body:
          user == null
              ? const Center(child: Text("User not signed in"))
              : StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('bookmarks')
                        .doc(user.uid)
                        .collection('items')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No bookmarks yet."));
                  }

                  final bookmarks = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: bookmarks.length,
                    itemBuilder: (context, index) {
                      final doc = bookmarks[index];
                      final original = doc['original'] ?? '';
                      final translated = doc['translated'] ?? '';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(
                            original,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(translated),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'speak') {
                                _speak(translated);
                              } else if (value == 'copy') {
                                _copyToClipboard(translated);
                              } else if (value == 'delete') {
                                FirebaseFirestore.instance
                                    .collection('bookmarks')
                                    .doc(user.uid)
                                    .collection('items')
                                    .doc(doc.id)
                                    .delete();
                              }
                            },
                            itemBuilder:
                                (context) => const [
                                  PopupMenuItem(
                                    value: 'speak',
                                    child: Text('Speak'),
                                  ),
                                  PopupMenuItem(
                                    value: 'copy',
                                    child: Text('Copy'),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete'),
                                  ),
                                ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
