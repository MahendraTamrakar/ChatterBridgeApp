/* import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class LanguageTranslator {
  late final OnDeviceTranslator _translator;

  Future<void> initialize(String sourceCode, String targetCode) async {
    final options = OnDeviceTranslatorOptions(
      sourceLanguage: TranslateLanguage.fromLanguageCode(sourceCode),
      targetLanguage: TranslateLanguage.fromLanguageCode(targetCode),
    );
    _translator = OnDeviceTranslator(options: options);
  }

  Future<String> translate(String text) async {
    return await _translator.translateText(text);
  }

  void dispose() {
    _translator.close();
  }

  Future<void> downloadModel(String languageCode) async {
    final manager = OnDeviceTranslatorModelManager();
    final lang = TranslateLanguage.fromLanguageCode(languageCode);
    final isDownloaded = await manager.isModelDownloaded(lang);
    if (!isDownloaded) {
      await manager.downloadModel(lang, isWifiRequired: true);
    }
  }

  Future<void> deleteModel(String languageCode) async {
    final manager = OnDeviceTranslatorModelManager();
    final lang = TranslateLanguage.fromLanguageCode(languageCode);
    await manager.deleteDownloadedModel(lang);
  }

  Future<bool> isModelAvailable(String languageCode) async {
    final manager = OnDeviceTranslatorModelManager();
    final lang = TranslateLanguage.fromLanguageCode(languageCode);
    return await manager.isModelDownloaded(lang);
  }
}
 */
