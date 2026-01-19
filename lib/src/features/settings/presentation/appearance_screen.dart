import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pasal/src/core/settings/background_provider.dart';
import 'package:pasal/src/core/theme/accent_color_provider.dart';
import 'package:pasal/src/core/theme/app_colors.dart';
import 'package:pasal/src/core/theme/theme_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:palette_generator/palette_generator.dart';

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  Future<void> _pickImage(WidgetRef ref) async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final fileName = image.path.split('/').last;
    final savedImage = await File(image.path).copy('${appDir.path}/$fileName');

    ref.read(backgroundImageProvider.notifier).setBackgroundImage(savedImage.path);

    // Generate accent color from image
    final paletteGenerator = await PaletteGenerator.fromImageProvider(
      FileImage(savedImage),
    );
    ref.read(accentColorProvider.notifier).state = paletteGenerator.dominantColor?.color;
  }

  void _removeImage(WidgetRef ref) {
    ref.read(backgroundImageProvider.notifier).setBackgroundImage(null);
    ref.read(accentColorProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);
    final backgroundImagePath = ref.watch(backgroundImageProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildFrostedCard(
            context,
            child: Column(
              children: [
                ListTile(
                  title: const Text('Theme'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ThemeColorCircle(color: Colors.white, isSelected: themeMode == ThemeMode.light, onTap: () => ref.read(themeNotifierProvider.notifier).setTheme(ThemeMode.light)),
                      const SizedBox(width: 12),
                      _ThemeColorCircle(color: Colors.black, isSelected: themeMode == ThemeMode.dark, onTap: () => ref.read(themeNotifierProvider.notifier).setTheme(ThemeMode.dark)),
                      const SizedBox(width: 24),
                      const Text('Adaptive'),
                      const SizedBox(width: 8),
                      Switch(
                        value: themeMode == ThemeMode.system,
                        onChanged: (isOn) {
                          ref.read(themeNotifierProvider.notifier).setTheme(isOn ? ThemeMode.system : (Theme.of(context).brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light));
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(),
                ListTile(
                  title: const Text('Background Image'),
                  subtitle: const Text('Select an image to use as the background'),
                  trailing: backgroundImagePath != null && backgroundImagePath != 'assets/images/background.jpeg'
                      ? Image.file(File(backgroundImagePath), width: 40, height: 40)
                      : const Icon(Icons.arrow_forward_ios),
                  onTap: () => _pickImage(ref),
                ),
                if (backgroundImagePath != null && backgroundImagePath != 'assets/images/background.jpeg')
                  ListTile(
                    title: const Text('Remove Background Image'),
                    trailing: const Icon(Icons.delete, color: Colors.red),
                    onTap: () => _removeImage(ref),
                  ),
              ],
            ),
          ),
        ],
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

class _ThemeColorCircle extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeColorCircle({required this.color, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 3,
                )
              : Border.all(color: Theme.of(context).dividerColor, width: 1.5),
        ),
      ),
    );
  }
}
