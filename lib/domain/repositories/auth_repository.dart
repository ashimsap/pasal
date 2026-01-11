import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pasal/core/network/dio_client.dart';
import 'package:pasal/core/network/shared_preferences_provider.dart';
import 'package:pasal/domain/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final Dio _dio;
  final SharedPreferences _sharedPreferences;

  AuthRepository(this._dio, this._sharedPreferences);

  Future<void> signIn(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      final token = response.data['token'];
      await _sharedPreferences.setString('token', token);
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } catch (e) {
      throw Exception('Failed to sign in');
    }
  }

  Future<void> signUp(String name, String email, String password) async {
    try {
      await _dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });
    } catch (e) {
      throw Exception('Failed to sign up');
    }
  }

  Future<void> signOut() async {
    await _sharedPreferences.remove('token');
    _dio.options.headers.remove('Authorization');
  }

  Future<User> getMe() async {
    try {
      final response = await _dio.get('/auth/me');
      return User.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get user');
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return AuthRepository(dio, sharedPreferences);
});
