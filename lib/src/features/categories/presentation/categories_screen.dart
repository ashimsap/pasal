import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pasal/src/core/theme/app_colors.dart';
import 'package:pasal/src/features/categories/application/category_providers.dart';
import 'package:pasal/src/features/products/application/product_providers.dart';
import 'package:pasal/src/features/products/presentation/product_card.dart';

final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  final Map<String, GlobalKey> _categoryKeys = {};

  void _scrollToSelected(String categoryTitle) {
    final key = _categoryKeys[categoryTitle];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        alignment: 0.5, // Center the item
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final filteredProducts = ref.watch(productsByCategoryProvider(selectedCategory));

    return Column(
      children: [
        categoriesAsync.when(
          data: (categories) {
            final fullCategoryList = ['All', ...categories.map((c) => c.title)];
            // Ensure keys exist for all categories
            for (var title in fullCategoryList) {
              _categoryKeys.putIfAbsent(title, () => GlobalKey());
            }

            return SizedBox(
              height: 60, // Increased height for better padding
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                itemCount: fullCategoryList.length,
                itemBuilder: (context, index) {
                  final categoryTitle = fullCategoryList[index];
                  final isSelected = categoryTitle == selectedCategory;
                  return Padding(
                    key: _categoryKeys[categoryTitle], // Assign key
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: _CategoryChip(
                      label: categoryTitle,
                      isSelected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          ref.read(selectedCategoryProvider.notifier).state = categoryTitle;
                          // Scroll after state has been updated
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _scrollToSelected(categoryTitle);
                          });
                        }
                      },
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const SizedBox(height: 60),
          error: (e, st) => const SizedBox(height: 60),
        ),
        Expanded(
          child: filteredProducts.isEmpty
              ? const Center(child: Text('No products found in this category.'))
              : GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return ProductCard(product: product);
                  },
                ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  const _CategoryChip({required this.label, required this.isSelected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final Color unselectedTint = isDarkMode ? AppColors.darkFrostedTint : AppColors.lightFrostedTint;
    final Color backgroundColor = isSelected ? theme.colorScheme.primary : unselectedTint;
    final Color labelColor = isSelected ? theme.colorScheme.onPrimary : (isDarkMode ? Colors.white : Colors.black87);
    final Border? border = isSelected ? null : Border.all(color: isDarkMode ? AppColors.darkFrostedBorder : AppColors.lightFrostedBorder, width: 1.5);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: GestureDetector(
          onTap: () => onSelected(true),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(20.0),
              border: border,
            ),
            child: Text(
              label,
              style: TextStyle(color: labelColor, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
