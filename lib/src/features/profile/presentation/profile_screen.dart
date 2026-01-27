import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pasal/src/core/theme/app_colors.dart';
import 'package:pasal/src/features/auth/application/providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    final textTheme = Theme.of(context).textTheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDarkMode ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.black54;

    if (user == null) {
      return const Center(child: Text('No user data found.'));
    }

    return ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // === UNIFIED USER & STATS HEADER ===
          _buildFrostedCard(
            context,
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.transparent,
                      backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                      child: user.photoURL == null
                          ? Icon(Icons.person, size: 35, color: secondaryTextColor)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.displayName ?? 'Pasal User',
                            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: primaryTextColor),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                user.email ?? 'No email',
                                style: textTheme.bodyMedium?.copyWith(color: secondaryTextColor),
                              ),
                              if (user.emailVerified)
                                const Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Icon(Icons.verified, color: Colors.blue, size: 18),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Divider(height: 1, thickness: 0.5),
                ),
                IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(context, 'Wishlist', '12', () { /* TODO: Navigate to wishlist */ }),
                      const VerticalDivider(thickness: 0.5),
                      _buildStatItem(context, 'Coupons', '5', () { /* TODO: Navigate to coupons */ }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // === ORDERS SECTION ===
           _buildFrostedCard(
            context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text('My Orders', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: primaryTextColor)),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildOrderItem(context, Icons.pending_actions_outlined, 'Pending', () {}),
                      const SizedBox(width: 16),
                      _buildOrderItem(context, Icons.local_shipping_outlined, 'Shipped', () {}),
                      const SizedBox(width: 16),
                      _buildOrderItem(context, Icons.rate_review_outlined, 'Review', () {}),
                      const SizedBox(width: 16),
                      _buildOrderItem(context, Icons.all_inbox_outlined, 'Pre-order', () {}),
                      const SizedBox(width: 16),
                      _buildOrderItem(context, Icons.check_circle_outline, 'Delivered', () {}),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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

  Widget _buildStatItem(BuildContext context, String title, String count, VoidCallback onTap) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDarkMode ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final subtitleColor = isDarkMode ? Colors.white70 : Colors.black54;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(count, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: titleColor)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: subtitleColor)),
        ],
      ),
    );
  }

    Widget _buildOrderItem(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDarkMode ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final iconColor = Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: iconColor),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 12, color: labelColor)),
          ],
        ),
      ),
    );
  }
}
