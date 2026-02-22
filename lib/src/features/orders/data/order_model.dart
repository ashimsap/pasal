import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pasal/src/features/address/data/address_model.dart';
import 'package:pasal/src/features/cart/data/cart_item_model.dart';

class Order {
  final String id;
  final String userId;
  final List<CartItem> items;
  final Address shippingAddress;
  final String paymentMethod;
  final double subtotal;
  final double shippingCost;
  final double total;
  final DateTime orderDate;
  final String status;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.subtotal,
    required this.shippingCost,
    required this.total,
    required this.orderDate,
    this.status = 'Pending',
  });

  factory Order.fromMap(Map<String, dynamic> map, String id) {
    return Order(
      id: id,
      userId: map['userId'] ?? '',
      items: (map['items'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList(),
      shippingAddress: Address.fromJson(map['shippingAddress'], map['shippingAddress']['id'] ?? ''),
      paymentMethod: map['paymentMethod'] ?? '',
      subtotal: map['subtotal']?.toDouble() ?? 0.0,
      shippingCost: map['shippingCost']?.toDouble() ?? 0.0,
      total: map['total']?.toDouble() ?? 0.0,
      orderDate: (map['orderDate'] as Timestamp).toDate(),
      status: map['status'] ?? '',
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'shippingAddress': shippingAddress.toJson(),
      'paymentMethod': paymentMethod,
      'subtotal': subtotal,
      'shippingCost': shippingCost,
      'total': total,
      'orderDate': Timestamp.fromDate(orderDate),
      'status': status,
    };
  }
}
