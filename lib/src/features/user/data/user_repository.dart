import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pasal/src/features/user/data/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  UserRepository(this._firestore, this._auth);

  User? get _currentUser => _auth.currentUser;

  // Get the current user's document stream as a UserModel
  Stream<UserModel> getUser() {
    if (_currentUser == null) {
      throw Exception('User not logged in');
    }
    return _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .snapshots()
        .map((doc) => UserModel.fromDoc(doc));
  }

  // Update user profile data
  Future<void> updateUserProfile(String displayName, String phoneNumber) async {
    if (_currentUser == null) {
      throw Exception('User not logged in');
    }

    // Update display name in Firebase Auth
    await _currentUser!.updateDisplayName(displayName);

    // Update display name and phone number in Firestore
    return _firestore.collection('users').doc(_currentUser!.uid).set({
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'email': _currentUser!.email, // Ensure email is also stored
    }, SetOptions(merge: true));
  }

  // Update the user's country
  Future<void> updateUserCountry(String country) {
    if (_currentUser == null) {
      throw Exception('User not logged in');
    }
    return _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .set({'country': country}, SetOptions(merge: true));
  }
}
