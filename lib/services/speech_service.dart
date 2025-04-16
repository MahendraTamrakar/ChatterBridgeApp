import 'package:speech_to_text/speech_to_text.dart';

SpeechToText _speech = SpeechToText();
// ignore: unused_element
String _recognized = "";

Future<void> startListening(Function(String) onResult) async {
  bool available = await _speech.initialize();
  if (available) {
    _speech.listen(onResult: (val) => onResult(val.recognizedWords));
  }
}

void stopListening() {
  _speech.stop();
}
