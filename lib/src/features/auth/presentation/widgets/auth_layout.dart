import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pasal/src/core/settings/background_provider.dart';
import 'package:pasal/src/core/theme/app_theme.dart';

class AuthLayout extends ConsumerWidget {
  final Widget form;

  const AuthLayout({super.key, required this.form});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backgroundImage = ref.watch(authBackgroundProvider);
    final isWideScreen = MediaQuery.of(context).size.width > 800;

    final formContent = Theme(
      data: AppTheme.darkTheme, // Force dark theme for the form
      child: form,
    );

    if (isWideScreen) {
      return Scaffold(
        body: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(backgroundImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(48),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: formContent,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Mobile Layout
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(backgroundImage),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  color: Colors.transparent, // This ensures pure blur
                  child: formContent,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
