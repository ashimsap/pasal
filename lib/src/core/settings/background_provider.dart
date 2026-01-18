import 'package:flutter_riverpod/flutter_riverpod.dart';

// This provider will hold the path to the background image.
// Later, a settings page can modify this state.
final authBackgroundProvider = StateProvider<String>((ref) {
  // Default background image path
  return 'assets/images/background.jpeg';
});
