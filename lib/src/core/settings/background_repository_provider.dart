import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pasal/src/core/settings/background_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider that initializes SharedPreferences asynchronously
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

// Provider for the BackgroundRepository
final backgroundRepositoryProvider = Provider<BackgroundRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).asData?.value;
  if (prefs == null) {
    // This should not happen in a real scenario once the app is running
    throw Exception('SharedPreferences not initialized');
  }
  return BackgroundRepository(prefs);
});
