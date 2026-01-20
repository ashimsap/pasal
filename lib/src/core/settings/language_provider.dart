import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1. Provider to expose the Notifier
final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>((ref) {
  return LanguageNotifier();
});

// 2. The Notifier itself
class LanguageNotifier extends StateNotifier<Locale> {
  static const String _languageCodeKey = 'languageCode';
  // Default to English
  LanguageNotifier() : super(const Locale('en')) {
    _loadLanguage();
  }

  // Load saved language from storage
  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageCodeKey);
    if (languageCode != null) {
      state = Locale(languageCode);
    }
  }

  // Change language and save to storage
  Future<void> setLanguage(String languageCode) async {
    if (state.languageCode == languageCode) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageCodeKey, languageCode);
    state = Locale(languageCode);
  }
}
