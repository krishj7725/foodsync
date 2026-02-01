import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'dart:ui'; 

import 'features/grocery_list/screens/grocery_screen.dart';
import 'features/recipes/screens/recipe_screen.dart'; 

final navIndexProvider = StateProvider<int>((ref) => 0);

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navIndexProvider);

    final List<Widget> pages = [
      const GroceryScreen(),
      const RecipeScreen(), 
    ];

    return Scaffold(
      extendBody: true,
      body: pages[selectedIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // GLASS NAV
            ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: GNav(
                      rippleColor: Colors.grey[800]!,
                      hoverColor: Colors.grey[900]!,
                      gap: 8,
                      activeColor: Colors.black,
                      iconSize: 24,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      duration: const Duration(milliseconds: 300),
                      tabBackgroundColor: Colors.white,
                      color: Colors.white60,
                      tabs: const [
                        GButton(
                          icon: Icons.shopping_basket_rounded,
                          text: 'Grocery',
                        ),
                        GButton(
                          icon: Icons.restaurant_menu_rounded,
                          text: 'Recipes',
                        ),
                      ],
                      selectedIndex: selectedIndex,
                      onTabChange: (index) {
                        HapticFeedback.lightImpact();
                        ref.read(navIndexProvider.notifier).state = index;
                      },
                    ),
                  ),
                ),
              ),
            ),

            // DYNAMIC ADD BUTTON
            AnimatedScale(
              scale: selectedIndex == 0 ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.elasticOut,
              child: Padding(
                padding: const EdgeInsets.only(left: 15),
                child: FloatingActionButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    // CALLING THE NEW STATIC DIALOG METHOD
                    GroceryScreen.showAddDialog(context, ref);
                  },
                  backgroundColor: Colors.black,
                  elevation: 10,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: const Icon(Icons.add, color: Colors.white, size: 28),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}