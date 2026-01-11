import 'dart:ui';
import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;
  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Base background color
          Container(
            color: theme.scaffoldBackgroundColor,
          ),
          // Gradient blob shapes
          Positioned(
            top: -size.height * 0.15,
            left: -size.width * 0.4,
            child: Container(
              height: size.height * 0.5,
              width: size.width * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.6),
                    theme.colorScheme.secondary.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -size.height * 0.2,
            right: -size.width * 0.3,
            child: Container(
              height: size.height * 0.4,
              width: size.width * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.secondary.withOpacity(0.5),
                    theme.colorScheme.primary.withOpacity(0.5),
                  ],
                ),
              ),
            ),
          ),
          // Back button
          if (Navigator.canPop(context))
            Positioned(
              top: 40,
              left: 16,
              child: SafeArea(
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          // Centered content with blur effect
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.cardColor.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.cardColor.withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    child: child,
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
