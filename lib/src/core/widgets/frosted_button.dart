import 'package:flutter/material.dart';
import 'package:pasal/src/core/widgets/frosted_card.dart';

class FrostedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const FrostedButton({super.key, required this.onPressed, required this.child});

  @override
  Widget build(BuildContext context) {
    return FrostedCard(
      padding: EdgeInsets.zero, // The card itself has no padding
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Center(child: child),
        ),
      ),
    );
  }
}
