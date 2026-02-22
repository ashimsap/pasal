import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pasal/src/features/auth/application/providers.dart';
import 'package:pasal/src/features/orders/application/order_providers.dart';
import 'package:pasal/src/features/orders/data/order_model.dart' as model;
import 'package:pasal/src/features/reviews/presentation/review_submission_screen.dart';

// Use a Family provider to pass the filter
final userOrdersStreamProvider =
    StreamProvider.autoDispose.family<List<model.Order>, String?>((ref, statusFilter) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final userId = ref.watch(authRepositoryProvider).currentUser?.uid;

  if (userId == null) {
    return Stream.value([]);
  }

  Query query = firestore
      .collection('orders')
      .where('userId', isEqualTo: userId);

  // Apply the status filter if it exists
  if (statusFilter != null && statusFilter.isNotEmpty) {
      // This is a dummy logic as the status is not saved in the DB
      // A real implementation would filter directly in the query
      // For now, we will filter on the client side after fetching
  }

  // Always sort by date
  query = query.orderBy('orderDate', descending: true);

  return query.snapshots().map((snapshot) {
    var orders = snapshot.docs.map((doc) => model.Order.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();

    // Client-side filtering based on dynamic status
    if (statusFilter != null && statusFilter.isNotEmpty) {
        final now = DateTime.now();
        orders = orders.where((order) {
            final daysSinceOrder = now.difference(order.orderDate).inDays;
            String dynamicStatus;
            if (daysSinceOrder < 1) dynamicStatus = 'Pending';
            else if (daysSinceOrder < 2) dynamicStatus = 'Shipped';
            else dynamicStatus = 'Delivered';

            if (statusFilter == 'Review') return dynamicStatus == 'Delivered';
            
            return dynamicStatus == statusFilter;
        }).toList();
    }

    return orders;
  });
});

class MyOrdersScreen extends ConsumerWidget {
  final String? statusFilter;
  const MyOrdersScreen({super.key, this.statusFilter});

  String _getDynamicStatus(DateTime orderDate) {
    final daysSinceOrder = DateTime.now().difference(orderDate).inDays;
    if (daysSinceOrder < 1) return 'Pending';
    if (daysSinceOrder < 2) return 'Shipped';
    return 'Delivered';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Pass the filter to the provider
    final ordersAsync = ref.watch(userOrdersStreamProvider(statusFilter));

    return Scaffold(
      appBar: AppBar(
        title: Text(statusFilter != null ? '$statusFilter Orders' : 'My Orders'),
      ),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return Center(child: Text(statusFilter != null 
                ? 'No orders with status \'$statusFilter\'.'
                : 'You have no orders yet.'));
          }
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final dynamicStatus = _getDynamicStatus(order.orderDate);

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order ID: ${order.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Total: NPR ${order.total.toStringAsFixed(2)}'),
                      Text('Status: $dynamicStatus'), 
                      Text('Date: ${order.orderDate.toLocal().toString().split(' ')[0]}'),

                      if (dynamicStatus == 'Delivered')
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ReviewSubmissionScreen(order: order),
                                ),
                              );
                            },
                            child: const Text('Write a Review'),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error fetching orders: $err')),
      ),
    );
  }
}
