import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pasal/src/core/theme/app_colors.dart';
import 'package:pasal/src/features/user/application/user_providers.dart';

class CountrySelectionScreen extends ConsumerWidget {
  const CountrySelectionScreen({super.key});

  static const List<String> _countries = [
    'Nepal',
    'India',
    'USA',
    'Canada',
    'United Kingdom',
    'Australia',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Country'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: userAsync.when(
        data: (user) {
          final selectedCountry = user.country ?? 'Nepal';
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _countries.length,
            itemBuilder: (context, index) {
              final country = _countries[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: _buildFrostedCard(
                  context,
                  child: ListTile(
                    title: Text(country),
                    trailing: selectedCountry == country
                        ? const Icon(Icons.check, color: Colors.blue)
                        : null,
                    onTap: () {
                      ref.read(userRepositoryProvider).updateUserCountry(country);
                      // Navigator.of(context).pop(); // Removed this line
                    },
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
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
