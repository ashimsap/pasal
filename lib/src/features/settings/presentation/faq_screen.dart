import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pasal/src/core/theme/app_colors.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Frequently Asked Questions'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          _FaqItem(
            question: 'How do I track my order?',
            answer:
                'You can track your order status in the \'My Orders\' section of your account. Once an order is shipped, you will receive a tracking number.',
          ),
          _FaqItem(
            question: 'What is your return policy?',
            answer:
                'We accept returns within 30 days of purchase for items that are unused and in their original packaging. Please visit our Policies page for more details.',
          ),
          _FaqItem(
            question: 'How do I change my shipping address?',
            answer:
                'You can add, edit, or delete shipping addresses from the \'Address Book\' in your account settings.',
          ),
           _FaqItem(
            question: 'What payment methods do you accept?',
            answer:
                'We accept all major credit cards, as well as digital wallets like eSewa and Khalti for a seamless checkout experience.',
          ),
        ],
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color tint = isDarkMode ? AppColors.darkFrostedTint : AppColors.lightFrostedTint;
    final Color borderColor = isDarkMode ? AppColors.darkFrostedBorder : AppColors.lightFrostedBorder;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Container(
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: ExpansionTile(
              title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600)),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(answer),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
