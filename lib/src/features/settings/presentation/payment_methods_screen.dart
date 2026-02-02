import 'package:flutter/material.dart';
import 'package:pasal/src/core/widgets/frosted_card.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  // Data for payment gateways
  static const List<Map<String, String>> _paymentGateways = [
    {
      'title': 'Khalti Wallet',
      'logoUrl': 'https://web.khalti.com/samagri/img/logo1.png',
    },
    {
      'title': 'eSewa',
      'logoUrl': 'https://esewa.com.np/common/images/esewa_logo.png',
    },
    {
      'title': 'Fonepay',
      'logoUrl': 'https://fonepay.com/images/logos/fonepay.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _paymentGateways.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Two items per row
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.9, // Adjust aspect ratio for a taller card
        ),
        itemBuilder: (context, index) {
          final gateway = _paymentGateways[index];
          return GestureDetector(
            onTap: () { /* TODO: Implement linking logic */ },
            child: FrostedCard(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Image.network(
                      gateway['logoUrl']!,
                      fit: BoxFit.contain,
                      // Show a placeholder on error
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(child: Icon(Icons.error_outline, color: Colors.redAccent)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    gateway['title']!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
