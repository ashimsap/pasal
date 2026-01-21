import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pasal/src/core/widgets/frosted_card.dart';
import 'package:pasal/src/features/address/application/address_providers.dart';
import 'package:pasal/src/features/address/data/address_model.dart';
import 'package:uuid/uuid.dart';

class AddAddressScreen extends ConsumerStatefulWidget {
  const AddAddressScreen({super.key});

  @override
  ConsumerState<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends ConsumerState<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController(text: 'Nepal'); // Default country
  bool _isDefault = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _addressLine1Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final newAddress = Address(
      id: const Uuid().v4(),
      fullName: _fullNameController.text,
      addressLine1: _addressLine1Controller.text,
      city: _cityController.text,
      state: _stateController.text,
      postalCode: _postalCodeController.text,
      country: _countryController.text,
      isDefault: _isDefault,
    );

    try {
      await ref.read(addressRepositoryProvider).addAddress(newAddress);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save address: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Address'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: FrostedCard(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressLine1Controller,
                  decoration: const InputDecoration(labelText: 'Address Line 1'),
                   validator: (value) => value!.isEmpty ? 'Please enter an address' : null,
                ),
                 const SizedBox(height: 16),
                TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(labelText: 'City'),
                   validator: (value) => value!.isEmpty ? 'Please enter a city' : null,
                ),
                 const SizedBox(height: 16),
                TextFormField(
                  controller: _stateController,
                  decoration: const InputDecoration(labelText: 'State / Province'),
                   validator: (value) => value!.isEmpty ? 'Please enter a state' : null,
                ),
                 const SizedBox(height: 16),
                TextFormField(
                  controller: _postalCodeController,
                  decoration: const InputDecoration(labelText: 'Postal Code'),
                   validator: (value) => value!.isEmpty ? 'Please enter a postal code' : null,
                ),
                 const SizedBox(height: 16),
                TextFormField(
                  controller: _countryController,
                  decoration: const InputDecoration(labelText: 'Country'),
                   validator: (value) => value!.isEmpty ? 'Please enter a country' : null,
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Set as default address'),
                  value: _isDefault,
                  onChanged: (value) {
                    setState(() {
                      _isDefault = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveAddress,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: _isLoading
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white))
                      : const Text('SAVE ADDRESS'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
