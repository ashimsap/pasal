import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pasal/src/core/theme/app_colors.dart';
import 'package:pasal/src/features/cart/presentation/cart_screen.dart';
import 'package:pasal/src/features/home/presentation/home_screen.dart';
import 'package:pasal/src/features/profile/presentation/profile_screen.dart';
import 'package:pasal/src/features/deals/presentation/deals_screen.dart';
import 'package:pasal/src/features/categories/presentation/categories_screen.dart';
import 'package:pasal/src/features/settings/presentation/settings_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    const HomeScreen(),
    const DealsScreen(),
    const CategoriesScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  final List<String> _pageTitles = [
    '', // No title for home
    'Deals',
    'Categories',
    'My Cart',
    'My Account',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onIconTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _onIconTapped(0);
        }
      },
      child: Scaffold(
        appBar: _currentIndex == 0
            ? null
            : AppBar(
                title: Text(_pageTitles[_currentIndex]),
                backgroundColor: Colors.transparent,
                elevation: 0,
                actions: [
                  // Conditionally show the settings icon only on the profile page
                  if (_currentIndex == 4)
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDarkMode ? AppColors.darkFrostedTint : AppColors.lightFrostedTint,
                              border: Border.all(
                                  color: isDarkMode ? AppColors.darkFrostedBorder : AppColors.lightFrostedBorder,
                                  width: 1.5),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.settings_outlined),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: _pages,
        ),
        bottomNavigationBar: _buildTransparentNavBar(context),
      ),
    );
  }

  Widget _buildTransparentNavBar(BuildContext context) {
    return Container(
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, Icons.home_outlined, 0),
          _buildNavItem(context, Icons.local_offer_outlined, 1),
          _buildNavItem(context, Icons.grid_view_outlined, 2),
          _buildNavItem(context, Icons.shopping_cart_outlined, 3),
          _buildNavItem(context, Icons.person_outline, 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, int index) {
    final isSelected = _currentIndex == index;
    final color = isSelected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).unselectedWidgetColor;

    return IconButton(
      icon: Icon(
        icon,
        color: color,
        size: isSelected ? 30 : 24,
      ),
      onPressed: () => _onIconTapped(index),
    );
  }
}
