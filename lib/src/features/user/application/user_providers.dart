import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pasal/src/features/auth/application/providers.dart';
import 'package:pasal/src/features/user/data/user_model.dart';
import 'package:pasal/src/features/user/data/user_repository.dart';
import 'package:pasal/src/features/address/application/address_providers.dart'; // For firestoreProvider

// Provider for the UserRepository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.watch(firestoreProvider), ref.watch(firebaseAuthProvider));
});

// StreamProvider for the UserModel
final userProvider = StreamProvider<UserModel>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return userRepository.getUser();
});
