import 'package:flutter/material.dart';
import 'package:pasal/src/core/theme/app_colors.dart';

class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.background,
            AppColors.primary.withOpacity(0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: _buildBlob(context, 200),
          ),
          Positioned(
            bottom: -150,
            right: -150,
            child: _buildBlob(context, 300),
          ),
        ],
      ),
    );
  }

  Widget _buildBlob(BuildContext context, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
    );
  }
}
