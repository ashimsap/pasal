import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pasal/src/features/address/data/address_model.dart';
import 'package:pasal/src/features/address/data/address_repository.dart';
import 'package:pasal/src/features/auth/application/providers.dart';

// Provider for the Firestore instance
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Provider for the AddressRepository
final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  return AddressRepository(ref.watch(firestoreProvider), ref.watch(firebaseAuthProvider));
});

// StreamProvider to get the list of addresses for the current user
final addressesStreamProvider = StreamProvider<List<Address>>((ref) {
  final addressRepository = ref.watch(addressRepositoryProvider);
  return addressRepository.getAddresses();
});
