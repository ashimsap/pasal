import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

const String _backgroundPathKey = 'user_background_path';

class BackgroundRepository {
  final SharedPreferences _prefs;

  BackgroundRepository(this._prefs);

  // Method to get the saved background path
  String? getBackgroundImagePath() {
    return _prefs.getString(_backgroundPathKey);
  }

  // Method to pick an image and save it
  Future<void> setNewBackgroundImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = path.basename(pickedFile.path);
      final savedImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');

      await _prefs.setString(_backgroundPathKey, savedImage.path);
    }
  }

  // Method to reset to the default background
  Future<void> resetToDefault() async {
    final savedPath = _prefs.getString(_backgroundPathKey);
    if (savedPath != null) {
      final file = File(savedPath);
      if (await file.exists()) {
        await file.delete();
      }
      await _prefs.remove(_backgroundPathKey);
    }
  }
}
