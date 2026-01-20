import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pasal/src/core/settings/language_provider.dart';
import 'package:pasal/src/core/theme/app_colors.dart';

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  static const Map<String, String> _languages = {
    'en': 'English',
    'ne': 'नेपाली',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLocale = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Language'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _languages.length,
        itemBuilder: (context, index) {
          final code = _languages.keys.elementAt(index);
          final name = _languages.values.elementAt(index);

          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            // By replacing the ListTile with a custom InkWell and Row,
            // we get full control over padding for a more compact card.
            child: _buildFrostedCard(
              context,
              child: InkWell(
                onTap: () {
                  ref.read(languageProvider.notifier).setLanguage(code);
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      if (selectedLocale.languageCode == code)
                        const Icon(Icons.check, color: Colors.blue, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFrostedCard(BuildContext context, {required Widget child}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color tint = isDarkMode ? AppColors.darkFrostedTint : AppColors.lightFrostedTint;
    final Color borderColor = isDarkMode ? AppColors.darkFrostedBorder : AppColors.lightFrostedBorder;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: child,
        ),
      ),
    );
  }
}
