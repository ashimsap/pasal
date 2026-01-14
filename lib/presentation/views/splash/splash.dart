import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pasal/presentation/providers/auth_provider.dart';
import 'package:pasal/presentation/views/auth/sign_in.dart';
import 'package:pasal/presentation/views/main_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), _checkAuthAndNavigate);
  }

  void _checkAuthAndNavigate() {
    if (!mounted) return;
    final authState = ref.read(authProvider);
    authState.whenOrNull(
      authenticated: (_) => Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      ),
      unauthenticated: () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SignInScreen()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (!mounted) return;
      next.whenOrNull(
        authenticated: (_) => Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        ),
        unauthenticated: () => Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SignInScreen()),
        ),
      );
    });

    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Pasal', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Icon(Icons.store, size: 50),
          ],
        ),
      ),
    );
  }
}
