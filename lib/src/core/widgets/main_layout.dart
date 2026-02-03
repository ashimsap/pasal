import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pasal/src/core/settings/background_provider.dart';
import 'package:pasal/src/core/widgets/glassmorphic_container.dart';

class MainLayout extends ConsumerWidget {
  final Widget child;
  final String title;

  const MainLayout({super.key, required this.child, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backgroundImagePath = ref.watch(backgroundImageProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(title,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          if (backgroundImagePath != null && File(backgroundImagePath).existsSync())
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: FileImage(File(backgroundImagePath)),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(
              color: Theme.of(context).colorScheme.background,
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GlassmorphicContainer(
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
