import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pasal/src/features/cart/data/cart_item_model.dart';
import 'package:pasal/src/features/products/data/product_model.dart';

class CartRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CartRepository(this._firestore, this._auth);

  User? get _currentUser => _auth.currentUser;

  CollectionReference<CartItem> get _cartRef => 
      _firestore.collection('users').doc(_currentUser!.uid).collection('cart').withConverter<CartItem>(
        fromFirestore: (snapshot, _) => CartItem.fromJson(snapshot.data()!),
        toFirestore: (cartItem, _) => cartItem.toJson(),
      );

  Stream<List<CartItem>> watchCart() {
     if (_currentUser == null) {
      return Stream.value([]);
    }
    return _cartRef.snapshots().map((snapshot) => 
      snapshot.docs.map((doc) => doc.data()).toList()
    );
  }

  Future<void> addToCart(Product product) async {
    if (_currentUser == null) throw Exception('User not logged in');

    final docRef = _cartRef.doc(product.id);
    final doc = await docRef.get();

    if (doc.exists) {
      docRef.update({'quantity': FieldValue.increment(1)});
    } else {
      final newItem = CartItem(
        productId: product.id,
        productName: product.name,
        price: product.price,
        imageUrl: product.imageUrls.isNotEmpty ? product.imageUrls[0] : '',
        quantity: 1,
      );
      await docRef.set(newItem);
    }
  }

  Future<void> updateQuantity(String productId, int quantity) {
    if (_currentUser == null) throw Exception('User not logged in');
    // Allow quantity to be 0, but not negative
    if (quantity >= 0) { 
      return _cartRef.doc(productId).update({'quantity': quantity});
    } else {
      return _cartRef.doc(productId).update({'quantity': 0});
    }
  }

  Future<void> removeFromCart(String productId) {
    if (_currentUser == null) throw Exception('User not logged in');
    return _cartRef.doc(productId).delete();
  }

  Future<void> removeSelectedFromCart(Set<String> productIds) async {
    if (_currentUser == null) throw Exception('User not logged in');

    final WriteBatch batch = _firestore.batch();
    for (final productId in productIds) {
      batch.delete(_cartRef.doc(productId));
    }
    return batch.commit();
  }

  Future<void> clearCart() async {
    if (_currentUser == null) throw Exception('User not logged in');

    final WriteBatch batch = _firestore.batch();
    final querySnapshot = await _cartRef.get();
    for (final doc in querySnapshot.docs) {
      batch.delete(doc.reference);
    }
    return batch.commit();
  }
}
