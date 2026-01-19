import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pasal/src/core/settings/background_provider.dart';

class AuthLayout extends ConsumerWidget {
  final Widget form;

  const AuthLayout({super.key, required this.form});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backgroundImagePath = ref.watch(backgroundImageProvider);
    final isWideScreen = MediaQuery.of(context).size.width > 800;

    final formContent = Theme(
      data: Theme.of(context).copyWith(
        brightness: Brightness.dark,
        // Ensure input fields and other form elements have a dark theme
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          labelStyle: TextStyle(color: Colors.white),
        ),
      ),
      child: form,
    );

    Widget background = backgroundImagePath != null && File(backgroundImagePath).existsSync()
        ? Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: FileImage(File(backgroundImagePath)),
                fit: BoxFit.cover,
              ),
            ),
          )
        : Container(
            color: Theme.of(context).colorScheme.background,
          );

    if (isWideScreen) {
      return Scaffold(
        body: Row(
          children: [
            Expanded(child: background),
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
      body: Stack(
        children: [
          background,
          Center(
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
        ],
      ),
    );
  }
}
