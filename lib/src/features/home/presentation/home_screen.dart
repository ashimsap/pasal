import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pasal/src/core/theme/app_colors.dart';
import 'package:pasal/src/features/products/application/product_providers.dart';
import 'package:pasal/src/features/products/data/product_model.dart';
import 'package:pasal/src/features/products/presentation/product_card.dart';

// 1. Enums and Providers for sorting
enum SortOption { off, lowToHigh, highToLow }

final searchQueryProvider = StateProvider<String>((ref) => '');
final priceSortProvider = StateProvider<SortOption>((ref) => SortOption.off);
final ratingSortProvider = StateProvider<SortOption>((ref) => SortOption.off);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: ref.read(searchQueryProvider));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsStreamProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final priceSort = ref.watch(priceSortProvider);
    final ratingSort = ref.watch(ratingSortProvider);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: _buildFrostedSearchBar(context, ref),
          ),
          // 2. Conditionally show sort chips
          Visibility(
            visible: searchQuery.isNotEmpty,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSortChip(
                    context,
                    label: 'Price',
                    sortOption: priceSort,
                    onTap: () {
                      final nextState = SortOption.values[(priceSort.index + 1) % SortOption.values.length];
                      ref.read(priceSortProvider.notifier).state = nextState;
                      ref.read(ratingSortProvider.notifier).state = SortOption.off; // Reset other sort
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildSortChip(
                    context,
                    label: 'Rating',
                    sortOption: ratingSort,
                    onTap: () {
                      final nextState = SortOption.values[(ratingSort.index + 1) % SortOption.values.length];
                      ref.read(ratingSortProvider.notifier).state = nextState;
                      ref.read(priceSortProvider.notifier).state = SortOption.off; // Reset other sort
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: productsAsync.when(
              data: (products) {
                var filteredProducts = products
                    .where((p) => p.name.toLowerCase().contains(searchQuery.toLowerCase()))
                    .toList();

                if (priceSort != SortOption.off) {
                  filteredProducts.sort((a, b) => priceSort == SortOption.lowToHigh
                      ? a.price.compareTo(b.price)
                      : b.price.compareTo(a.price));
                } else if (ratingSort != SortOption.off) {
                  filteredProducts.sort((a, b) => ratingSort == SortOption.lowToHigh
                      ? a.rating.rate.compareTo(b.rating.rate)
                      : b.rating.rate.compareTo(a.rating.rate));
                }

                if (filteredProducts.isEmpty) {
                  return const Center(child: Text('No products found.'));
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    return ProductCard(product: filteredProducts[index]);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrostedSearchBar(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color tint = isDarkMode ? AppColors.darkFrostedTint : AppColors.lightFrostedTint;
    final Color borderColor = isDarkMode ? AppColors.darkFrostedBorder : AppColors.lightFrostedBorder;

    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => ref.read(searchQueryProvider.notifier).state = value,
            decoration: InputDecoration(
              icon: const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Icon(Icons.search),
              ),
              hintText: 'Search for products...',
              border: InputBorder.none,
              suffixIcon: ref.watch(searchQueryProvider).isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        ref.read(searchQueryProvider.notifier).state = '';
                        _searchController.clear();
                        FocusScope.of(context).unfocus();
                      },
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSortChip(BuildContext context, {required String label, required SortOption sortOption, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final Color tint = isDarkMode ? AppColors.darkFrostedTint : AppColors.lightFrostedTint;
    final Color borderColor = isDarkMode ? AppColors.darkFrostedBorder : AppColors.lightFrostedBorder;

    IconData? chipIcon;
    if (sortOption == SortOption.lowToHigh) {
      chipIcon = Icons.arrow_upward;
    } else if (sortOption == SortOption.highToLow) {
      chipIcon = Icons.arrow_downward;
    }

    final Color backgroundColor = sortOption != SortOption.off ? theme.colorScheme.primary.withOpacity(0.7) : tint;
    final Color contentColor = sortOption != SortOption.off ? theme.colorScheme.onPrimary : (isDarkMode ? Colors.white : Colors.black87);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(fontWeight: FontWeight.bold, color: contentColor),
                ),
                if (chipIcon != null) ...[
                  const SizedBox(width: 4),
                  Icon(chipIcon, size: 16, color: contentColor),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
