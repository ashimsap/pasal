import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pasal/firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pasal/src/core/theme/accent_color_provider.dart';
import 'package:pasal/src/core/theme/app_theme.dart';
import 'package:pasal/src/core/theme/theme_provider.dart';
import 'package:pasal/src/core/widgets/app_background.dart';
import 'package:pasal/src/features/auth/application/providers.dart';
import 'package:pasal/src/features/auth/presentation/auth_wrapper.dart';
import 'package:pasal/src/features/notifications/application/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load the .env file
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set the background messaging handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);
    final accentColor = ref.watch(accentColorProvider);
    final authState = ref.watch(authStateChangesProvider);

    // Initialize notification service when user logs in
    ref.listen<AsyncValue>(authStateChangesProvider, (_, state) {
      state.whenData((user) {
        if (user != null) {
          ref.read(notificationServiceProvider).initNotifications();
        }
      });
    });

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(accentColor ?? Colors.teal, Brightness.light),
      darkTheme: AppTheme.getTheme(accentColor ?? Colors.teal, Brightness.dark),
      themeMode: themeMode,
      home: const AuthWrapper(),
      builder: (context, child) {
        // Determine if we are on an authentication screen
        final isAuthScreen = authState.when(
          data: (user) => user == null,
          loading: () => true, // Assume auth screen while loading
          error: (_, __) => true, // Assume auth screen on error
        );

        final content = child ?? const SizedBox();

        return AppBackground(
          // The background blur should only be applied when the user is logged in
          blur: !isAuthScreen,
          // Conditionally wrap the auth screens with a fixed light theme
          child: isAuthScreen
              ? Theme(
                  data: AppTheme.getTheme(accentColor ?? Colors.teal, Brightness.light),
                  child: content,
                )
              : content,
        );
      },
    );
  }
}
