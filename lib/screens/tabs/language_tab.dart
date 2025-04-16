import 'package:flutter/material.dart';

class LanguageTab extends StatelessWidget {
  final List<String> downloadedLanguages = ['Indonesia', 'English', 'Japan'];
  final List<String> allLanguages = [
    'Algeria',
    'Armenia',
    'Argentina',
    'Australia',
    'Bangladesh',
    'China',
    'France',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[200],
      appBar: AppBar(
        backgroundColor: Colors.amber[200],
        title: const Text(
          'Language',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextField(
              decoration: InputDecoration(
                hintText: 'Search Language',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Downloaded',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...downloadedLanguages.map((lang) => LanguageTile(language: lang)),
            const Divider(thickness: 1.2),
            const SizedBox(height: 10),
            const Text(
              'All Language',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: allLanguages.length,
                itemBuilder: (context, index) {
                  return LanguageTile(
                    language: allLanguages[index],
                    isDownloadable: true,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LanguageTile extends StatelessWidget {
  final String language;
  final bool isDownloadable;

  const LanguageTile({
    super.key,
    required this.language,
    this.isDownloadable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                language,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (isDownloadable)
            const Icon(Icons.cloud_download_outlined, color: Colors.grey),
        ],
      ),
    );
  }
}
