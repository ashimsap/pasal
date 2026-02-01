import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pasal/src/core/theme/app_colors.dart';
import 'package:pasal/src/features/auth/application/providers.dart';
import 'package:pasal/src/features/user/application/user_providers.dart';
import 'package:pasal/src/features/user/data/user_model.dart';

class AccountInformationScreen extends ConsumerStatefulWidget {
  const AccountInformationScreen({super.key});

  @override
  ConsumerState<AccountInformationScreen> createState() => _AccountInformationScreenState();
}

class _AccountInformationScreenState extends ConsumerState<AccountInformationScreen> {

  // Method to show the edit dialog
  Future<void> _showEditDialog(BuildContext context, UserModel user, String field) async {
    final controller = TextEditingController(
      text: field == 'Name' ? user.displayName : user.phoneNumber,
    );
    final formKey = GlobalKey<FormState>();

    final newValue = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $field'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a value';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(controller.text);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newValue != null) {
      final userRepo = ref.read(userRepositoryProvider);
      try {
        if (field == 'Name') {
          await userRepo.updateUserProfile(newValue, user.phoneNumber ?? '');
        } else {
          await userRepo.updateUserProfile(user.displayName ?? '', newValue);
        }
         if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$field updated successfully!')),
            );
          }
      } catch (e) {
         if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error updating $field: ${e.toString()}')),
            );
          }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userModelAsync = ref.watch(userProvider);
    final authRepo = ref.read(authRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Information'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: userModelAsync.when(
        data: (user) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildFrostedCard(
                context,
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Name'),
                      subtitle: Text(user.displayName ?? 'Not set'),
                      trailing: const Icon(Icons.edit_outlined, size: 20),
                      onTap: () => _showEditDialog(context, user, 'Name'),
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('Email'),
                      subtitle: Text(user.email ?? 'Not set'),
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('Phone Number'),
                      subtitle: Text(user.phoneNumber ?? 'Not set'),
                      trailing: const Icon(Icons.edit_outlined, size: 20),
                      onTap: () => _showEditDialog(context, user, 'Phone Number'),
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('Change Password'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        if (user.email != null) {
                          authRepo.sendPasswordResetEmail(user.email!);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Password reset link sent to your email.')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
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
