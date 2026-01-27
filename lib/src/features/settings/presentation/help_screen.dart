import 'package:flutter/material.dart';
import 'package:pasal/src/core/widgets/frosted_card.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@pasal.com',
      queryParameters: {
        'subject': 'Help Request from Pasal App'
      }
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      throw 'Could not launch $emailLaunchUri';
    }
  }

  Future<void> _launchPhone() async {
    final Uri phoneLaunchUri = Uri(
      scheme: 'tel',
      path: '+9779800000000',
    );
     if (await canLaunchUrl(phoneLaunchUri)) {
      await launchUrl(phoneLaunchUri);
    } else {
      throw 'Could not launch $phoneLaunchUri';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          FrostedCard(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(
                  'App Guidelines',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildGuideline(
                  context,
                  icon: Icons.shopping_cart_outlined,
                  title: 'Placing an Order',
                  description: 'To place an order, add items to your cart and proceed to checkout. You will be asked to select a shipping address and payment method. Once confirmed, your order will be placed.',
                ),
                const SizedBox(height: 16),
                _buildGuideline(
                  context,
                  icon: Icons.swap_horiz_outlined,
                  title: 'Returns & Exchanges',
                  description: 'You can request a return or exchange from the "My Orders" section within 7 days of delivery. Please ensure the product is in its original condition with all tags attached.',
                ),
                const SizedBox(height: 16),
                _buildGuideline(
                  context,
                  icon: Icons.track_changes_outlined,
                  title: 'Tracking Your Order',
                  description: 'Once your order is shipped, you will receive an email with tracking details. You can also find the tracking information in the "My Orders" section of your account.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
           FrostedCard(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contact Support',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Send us an email'),
                  subtitle: const Text('support@pasal.com'),
                  onTap: _launchEmail,
                ),
                ListTile(
                  leading: const Icon(Icons.phone_outlined),
                  title: const Text('Call us'),
                  subtitle: const Text('+977-9800000000'),
                  onTap: _launchPhone,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideline(BuildContext context, {required IconData icon, required String title, required String description}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(description),
            ],
          ),
        ),
      ],
    );
  }
}
