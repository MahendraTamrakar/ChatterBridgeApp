/* 
import 'package:chatter_bridge/services/language_dowload_services.dart';
import 'package:chatter_bridge/services/offline_translation_service.dart';

Future<String> handleTranslation(String input, String langCode) async {
  final isOnline = await ConnectivityService().isOnline();
  final isDownloaded = await LanguageDownloadService().isModelDownloaded(langCode);

  if (isOnline) {
    return await TranslationService().translateOnline(input, langCode);
  } else if (isDownloaded) {
    await OfflineTranslationService().loadModel(langCode);
    return await OfflineTranslationService().translate(input);
  } else {
    return "You're offline and this language is not downloaded.";
  }
}
 */
