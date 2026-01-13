import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pasal/core/network/dio_client.dart';
import 'package:pasal/domain/models/cart_item.dart';

class CartRepository {
  final Dio _dio;

  CartRepository(this._dio);

  Future<List<CartItem>> getCart() async {
    try {
      final response = await _dio.get('/cart');
      final data = response.data as List;
      return data.map((item) => CartItem.fromJson(item)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addToCart(String productId, int quantity) async {
    try {
      await _dio.post('/cart/add', data: {
        'productId': productId,
        'quantity': quantity,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateCart(String productId, int quantity) async {
    try {
      await _dio.put('/cart/update', data: {
        'productId': productId,
        'quantity': quantity,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeFromCart(String productId) async {
    try {
      await _dio.delete('/cart/remove/$productId');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> checkout() async {
    try {
      await _dio.post('/checkout');
    } catch (e) {
      rethrow;
    }
  }
}

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return CartRepository(dio);
});
