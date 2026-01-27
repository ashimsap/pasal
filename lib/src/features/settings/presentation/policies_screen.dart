import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pasal/src/core/theme/app_colors.dart';

class PoliciesScreen extends StatelessWidget {
  const PoliciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _buildFrostedCard(
          context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Privacy Policy for Pasal', style: textTheme.headlineSmall),
              const SizedBox(height: 8),
              const Text('Last updated: July 28, 2024'),
              const SizedBox(height: 16),
              const Text(
                'Welcome to Pasal. We are committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.'
              ),

              const SizedBox(height: 24),
              Text('1. Information We Collect', style: textTheme.titleLarge),
              const SizedBox(height: 8),
              const Text(
                'We may collect information about you in a variety of ways. The information we may collect on the Application includes: \n\n'
                '- Personal Data: Personally identifiable information, such as your name, shipping address, email address, and telephone number. \n'
                '- Derivative Data: Information our servers automatically collect when you access the Application, such as your IP address, your browser type, your operating system, your access times, and the pages you have viewed directly before and after accessing the Application.'
              ),

              const SizedBox(height: 24),
              Text('2. Use of Your Information', style: textTheme.titleLarge),
              const SizedBox(height: 8),
              const Text(
                'Having accurate information about you permits us to provide you with a smooth, efficient, and customized experience. Specifically, we may use information collected about you via the Application to: \n\n'
                '- Create and manage your account. \n'
                '- Fulfill and manage purchases, orders, payments, and other transactions related to the Application. \n'
                '- Email you regarding your account or order.'
              ),
               const SizedBox(height: 24),
              Text('3. Contact Us', style: textTheme.titleLarge),
              const SizedBox(height: 8),
              const Text(
                'If you have questions or comments about this Privacy Policy, please contact us at: support@pasal.com'
              ),
            ],
          ),
        ),
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
          padding: const EdgeInsets.all(16.0),
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
