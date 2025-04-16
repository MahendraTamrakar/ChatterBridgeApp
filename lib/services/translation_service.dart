import 'dart:convert';

import 'package:http/http.dart' as http;

Future<String> translateOnline(String text, String targetLang) async {
  final response = await http.post(
    Uri.parse('https://libretranslate.com/translate'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'q': text,
      'source': 'auto',
      'target': targetLang,
      'format': 'text',
    }),
  );
  return json.decode(response.body)['translatedText'];
}
