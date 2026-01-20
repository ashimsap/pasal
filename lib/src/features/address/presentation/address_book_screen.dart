import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pasal/src/core/theme/app_colors.dart';
import 'package:pasal/src/core/widgets/frosted_card.dart';
import 'package:pasal/src/features/address/application/address_providers.dart';
import 'package:pasal/src/features/address/presentation/add_address_screen.dart';
import 'package:pasal/src/features/address/presentation/edit_address_screen.dart';

class AddressBookScreen extends ConsumerWidget {
  const AddressBookScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressesAsync = ref.watch(addressesStreamProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Address Book'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDarkMode
                        ? AppColors.darkFrostedTint
                        : AppColors.lightFrostedTint,
                    border: Border.all(
                        color: isDarkMode
                            ? AppColors.darkFrostedBorder
                            : AppColors.lightFrostedBorder,
                        width: 1.5),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => const AddAddressScreen()),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: addressesAsync.when(
        data: (addresses) {
          if (addresses.isEmpty) {
            return const Center(
              child: Text(
                'No addresses found.\nTap the + button to add one!',
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final address = addresses[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: FrostedCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(address.fullName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                            if (address.isDefault)
                              const Chip(
                                  label: Text('Default'),
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                            '${address.addressLine1}\n${address.city}, ${address.state} ${address.postalCode}\n${address.country}'),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              child: const Text('Edit'),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          EditAddressScreen(address: address)),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              child: const Text('Delete'),
                              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                          title: const Text('Delete Address'),
                                          content: const Text(
                                              'Are you sure you want to delete this address?'),
                                          actions: [
                                            TextButton(
                                              child: const Text('Cancel'),
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                            ),
                                            TextButton(
                                                child: const Text('Delete'),
                                                style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                                                onPressed: () {
                                                  ref.read(addressRepositoryProvider).deleteAddress(address.id);
                                                  Navigator.of(context).pop();
                                                }),
                                          ],
                                        ));
                              },
                            ),
                          ],
                        )
                      ],
                    ),
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
}
