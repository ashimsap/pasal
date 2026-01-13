import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pasal/presentation/providers/auth_provider.dart';
import 'package:pasal/presentation/providers/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final isLoading = cartState.request.isLoading;

    // Listen for non-401 errors and show a SnackBar
    ref.listen<AsyncValue<void>>(
      cartProvider.select((state) => state.request),
      (previous, next) {
        if (next.hasError && !next.isLoading) {
          final is401Error = next.error is DioException &&
              (next.error as DioException).response?.statusCode == 401;

          if (!is401Error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(next.error.toString()),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
    );

    // Determine if the current error is a 401
    final is401Error = cartState.request.hasError &&
        cartState.request.error is DioException &&
        (cartState.request.error as DioException).response?.statusCode == 401;

    Widget body;

    if (is401Error) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_clock, color: Colors.amber, size: 80),
              const SizedBox(height: 24),
              const Text(
                'Session Expired',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Your session has expired. Please sign in again to continue.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  ref.read(authProvider.notifier).signOut();
                },
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      );
    } else if (isLoading && cartState.items.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else if (cartState.items.isEmpty && !isLoading) {
      body = Center(
        child: Text(
          'Your cart is empty.',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      );
    } else {
      body = Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartState.items.length,
              itemBuilder: (context, index) {
                final item = cartState.items[index];
                return ListTile(
                  leading: Image.network(item.imageUrl,
                      width: 50, height: 50, fit: BoxFit.cover),
                  title: Text(item.name),
                  subtitle: Text('Rs. ${item.price.toStringAsFixed(2)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: isLoading || item.quantity <= 1
                            ? null
                            : () => cartNotifier.updateCart(
                                item.id, item.quantity - 1),
                      ),
                      Text(item.quantity.toString()),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: isLoading
                            ? null
                            : () => cartNotifier.updateCart(
                                item.id, item.quantity + 1),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: isLoading
                            ? null
                            : () => cartNotifier.removeFromCart(item.id),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: Rs. ${cartState.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: isLoading || cartState.items.isEmpty
                      ? null
                      : () async {
                          await cartNotifier.checkout();
                          final newState = ref.read(cartProvider);
                          if (newState.request.hasError == false) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Checkout successful!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Checkout'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: () => cartNotifier.getCart(),
        child: body,
      ),
    );
  }
}
