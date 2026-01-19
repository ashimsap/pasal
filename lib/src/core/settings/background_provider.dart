import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final backgroundImageProvider = StateNotifierProvider<BackgroundImageNotifier, String?>((ref) {
  return BackgroundImageNotifier();
});

class BackgroundImageNotifier extends StateNotifier<String?> {
  static const _key = 'backgroundImagePath';
  static const _defaultAsset = 'assets/images/background.jpeg';

  BackgroundImageNotifier() : super(_defaultAsset) {
    _loadBackgroundImage();
  }

  Future<void> _loadBackgroundImage() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(_key) ?? _defaultAsset;
  }

  Future<void> setBackgroundImage(String? path) async {
    final prefs = await SharedPreferences.getInstance();
    if (path == null) {
      await prefs.remove(_key);
      state = _defaultAsset;
    } else {
      await prefs.setString(_key, path);
      state = path;
    }
  }
}
