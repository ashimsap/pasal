import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pasal/src/core/settings/background_provider.dart';

class AppBackground extends ConsumerWidget {
  final Widget child;
  final bool blur;

  const AppBackground({super.key, required this.child, this.blur = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backgroundImagePath = ref.watch(backgroundImageProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    ImageProvider? backgroundImage;

    if (backgroundImagePath != null) {
      if (backgroundImagePath.startsWith('assets/')) {
        backgroundImage = AssetImage(backgroundImagePath);
      } else {
        final file = File(backgroundImagePath);
        if (file.existsSync()) {
          backgroundImage = FileImage(file);
        }
      }
    }

    Widget backgroundWidget;
    if (backgroundImage != null) {
      backgroundWidget = Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: backgroundImage,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      backgroundWidget = Container(
        color: Theme.of(context).colorScheme.background,
      );
    }

    return Stack(
      children: [
        Positioned.fill(
          child: blur
              ? ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                  child: backgroundWidget,
                )
              : backgroundWidget,
        ),
        if (blur && !isDarkMode)
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
        child,
      ],
    );
  }
}
