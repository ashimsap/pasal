import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pasal/src/features/orders/data/order_model.dart' as model;

class OrderRepository {
  final FirebaseFirestore _firestore;

  OrderRepository(this._firestore);

  Future<void> addOrder(model.Order order) async {
    await _firestore.collection('orders').add(order.toMap());
  }
}
