// File: lib/services/language_download_service.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageDownloadService {
  static const String _downloadKey = 'downloaded_languages';

  /// Returns the local file path of the downloaded model
  Future<String> getModelPath(String langCode) async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$langCode.tflite';
  }

  /// Checks if a model has been downloaded
  Future<bool> isModelDownloaded(String langCode) async {
    final path = await getModelPath(langCode);
    return File(path).existsSync();
  }

  /// Downloads the TFLite model from a URL and saves it locally
  Future<void> downloadModel(String langCode, String downloadUrl) async {
    final path = await getModelPath(langCode);
    final file = File(path);

    // If already downloaded, skip
    if (await file.exists()) return;

    final dio = Dio();
    await dio.download(downloadUrl, path);
    await _markAsDownloaded(langCode);
  }

  /// Marks a language as downloaded in SharedPreferences
  Future<void> _markAsDownloaded(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    final downloaded = prefs.getStringList(_downloadKey) ?? [];
    if (!downloaded.contains(langCode)) {
      downloaded.add(langCode);
      await prefs.setStringList(_downloadKey, downloaded);
    }
  }

  /// Gets the list of downloaded languages
  Future<List<String>> getDownloadedLanguages() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_downloadKey) ?? [];
  }

  /// Removes the downloaded model and updates tracking
  Future<void> deleteModel(String langCode) async {
    final path = await getModelPath(langCode);
    final file = File(path);

    if (await file.exists()) {
      await file.delete();
    }

    final prefs = await SharedPreferences.getInstance();
    final downloaded = prefs.getStringList(_downloadKey) ?? [];
    downloaded.remove(langCode);
    await prefs.setStringList(_downloadKey, downloaded);
  }
}
