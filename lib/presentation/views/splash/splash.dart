import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pasal/presentation/providers/auth_provider.dart';
import 'package:pasal/presentation/views/auth/sign_in.dart';
import 'package:pasal/presentation/views/home/home.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Wait for a few seconds for the animation, then navigate.
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      final authState = ref.read(authProvider);
      authState.whenOrNull(
        authenticated: (_) => Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        ),
        unauthenticated: () => Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SignInScreen()),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // This listener handles any auth state changes that might happen
    // while the splash screen is still visible.
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (!mounted) return;
      next.whenOrNull(
        authenticated: (_) => Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        ),
        unauthenticated: () => Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SignInScreen()),
        ),
      );
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  'Pasal',
                  textStyle: const TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                  ),
                  speed: const Duration(milliseconds: 200),
                ),
              ],
              totalRepeatCount: 1,
            ),
            const SizedBox(height: 20),
            const Icon(
              Icons.store,
              size: 50,
            ),
          ],
        ),
      ),
    );
  }
}
