import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pasal/src/features/address/data/address_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddressRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  AddressRepository(this._firestore, this._auth);

  User? get _currentUser => _auth.currentUser;

  CollectionReference get _addressesRef => _firestore.collection('users').doc(_currentUser!.uid).collection('addresses');

  // Get a stream of addresses for the current user
  Stream<List<Address>> getAddresses() {
    if (_currentUser == null) {
      return Stream.value([]);
    }
    return _addressesRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Address.fromJson(doc.data() as Map<String, dynamic>, doc.id)).toList();
    });
  }

  // Add a new address, ensuring only one is default
  Future<void> addAddress(Address address) async {
    if (_currentUser == null) throw Exception('User not logged in');
    final batch = _firestore.batch();

    if (address.isDefault) {
      final querySnapshot = await _addressesRef.where('isDefault', isEqualTo: true).get();
      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {'isDefault': false});
      }
    }

    final newAddressRef = _addressesRef.doc(address.id);
    batch.set(newAddressRef, address.toJson());

    return batch.commit();
  }

  // Update an existing address
  Future<void> updateAddress(Address address) async {
    if (_currentUser == null) throw Exception('User not logged in');
    final batch = _firestore.batch();

    if (address.isDefault) {
      final querySnapshot = await _addressesRef.where('isDefault', isEqualTo: true).get();
      for (final doc in querySnapshot.docs) {
        if (doc.id != address.id) { // Don't unset itself
          batch.update(doc.reference, {'isDefault': false});
        }
      }
    }
    
    final addressRef = _addressesRef.doc(address.id);
    batch.update(addressRef, address.toJson());
    
    return batch.commit();
  }

  // Set an address as the default
  Future<void> setDefaultAddress(String addressId) async {
    if (_currentUser == null) throw Exception('User not logged in');
    final batch = _firestore.batch();

    final querySnapshot = await _addressesRef.where('isDefault', isEqualTo: true).get();
    for (final doc in querySnapshot.docs) {
      batch.update(doc.reference, {'isDefault': false});
    }

    final newDefaultRef = _addressesRef.doc(addressId);
    batch.update(newDefaultRef, {'isDefault': true});

    return batch.commit();
  }

  // Delete an address
  Future<void> deleteAddress(String addressId) async {
    if (_currentUser == null) throw Exception('User not logged in');

    final addressDoc = _addressesRef.doc(addressId);
    final addressSnapshot = await addressDoc.get();

    if (!addressSnapshot.exists) {
      return;
    }

    final addressData = addressSnapshot.data() as Map<String, dynamic>;
    final isDefault = addressData['isDefault'] ?? false;
    
    await addressDoc.delete();

    if (isDefault) {
      final remainingAddresses = await _addressesRef.limit(1).get();
      if (remainingAddresses.docs.isNotEmpty) {
        await setDefaultAddress(remainingAddresses.docs.first.id);
      }
    }
  }
}
