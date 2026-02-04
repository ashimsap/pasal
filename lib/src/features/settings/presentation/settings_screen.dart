import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pasal/src/core/theme/app_colors.dart';
import 'package:pasal/src/features/address/presentation/address_book_screen.dart';
import 'package:pasal/src/features/settings/presentation/appearance_screen.dart';
import 'package:pasal/src/features/settings/presentation/country_selection_screen.dart';
import 'package:pasal/src/features/settings/presentation/account_information_screen.dart';
import 'package:pasal/src/features/settings/presentation/faq_screen.dart';
import 'package:pasal/src/features/settings/presentation/language_screen.dart';
import 'package:pasal/src/features/settings/presentation/payment_methods_screen.dart';
import 'package:pasal/src/features/settings/presentation/policies_screen.dart';
import 'package:pasal/src/features/auth/application/providers.dart';
import 'package:pasal/src/features/products/application/product_providers.dart';
import 'package:pasal/src/features/settings/presentation/help_screen.dart';
import 'package:pasal/src/features/settings/presentation/feedback_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildFrostedSection(
              context,
              title: 'Account',
              children: [
                _buildSettingItem(context, Icons.account_circle_outlined, 'Account Information', () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const AccountInformationScreen()),
                  );
                }),
                _buildSettingItem(context, Icons.book_outlined, 'Address Book', () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const AddressBookScreen()),
                  );
                }),
                _buildSettingItem(context, Icons.credit_card_outlined, 'Payment Methods', () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const PaymentMethodsScreen()),
                  );
                }),
              ],
            ),
            const SizedBox(height: 16),
            _buildFrostedSection(
              context,
              title: 'Preferences',
              children: [
                _buildSettingItem(context, Icons.color_lens_outlined, 'Appearance', () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const AppearanceScreen()),
                  );
                }),
                _buildSettingItem(context, Icons.language_outlined, 'Language', () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const LanguageScreen()),
                  );
                }),
                _buildSettingItem(context, Icons.public_outlined, 'Country', () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const CountrySelectionScreen()),
                  );
                }),
              ],
            ),
            const SizedBox(height: 16),
            _buildFrostedSection(
              context,
              title: 'Help & Support',
              children: [
                 _buildSettingItem(context, Icons.question_answer_outlined, 'FAQ', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const FaqScreen()),
                    );
                  }),
                  _buildSettingItem(context, Icons.support_agent_outlined, 'Help', () {
                     Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const HelpScreen()),
                    );
                  }),
                  _buildSettingItem(context, Icons.feedback_outlined, 'Feedback', () {
                     Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const FeedbackScreen()),
                    );
                  }),
              ]
            ),
             const SizedBox(height: 16),
            _buildFrostedSection(
              context,
              title: 'Legal',
              children: [
                _buildSettingItem(context, Icons.policy_outlined, 'Policies', () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const PoliciesScreen()),
                  );
                }),
              ]
            ),
            const SizedBox(height: 16),
            _buildFrostedSection(
              context,
              title: 'Debug',
              children: [
                 _buildSettingItem(context, Icons.data_usage, 'Seed Products', () async {
                  try {
                    await ref.read(productRepositoryProvider).seedDatabase();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Successfully seeded products!')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error seeding products: ${e.toString()}')),
                    );
                  }
                }),
              ]
            ),
        
            const SizedBox(height: 32),
        
            ElevatedButton.icon(
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('LOGOUT'),
              onPressed: () {
                ref.read(authRepositoryProvider).signOut();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
             const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFrostedSection(BuildContext context, {required String title, required List<Widget> children}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDarkMode ? AppColors.darkOnSurface : AppColors.lightOnSurface;
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
              ),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDarkMode ? Colors.white70 : Colors.black54;
    final textColor = isDarkMode ? AppColors.darkOnSurface : AppColors.lightOnSurface;

    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: TextStyle(color: textColor)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: iconColor),
      onTap: onTap,
    );
  }
}
