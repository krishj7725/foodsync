import 'dart:io'; // <--- Required for File
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recipe.dart'; 
import '../../grocery_list/providers/grocery_provider.dart'; 
import '../../grocery_list/models/grocery_item.dart'; 
import '../providers/recipe_provider.dart'; 

class RecipeDetailScreen extends ConsumerWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // 1. IMAGE HEADER
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              // --- SMART IMAGE LOADER ---
              background: _buildRecipeImage(recipe.imageUrl),
              title: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  recipe.title,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              centerTitle: true,
            ),
            // --- DELETE BUTTON ---
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.8), 
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.white, size: 20),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Recipe?'),
                      content: const Text('This action cannot be undone.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                        ),
                        TextButton(
                          onPressed: () {
                            ref.read(recipeProvider.notifier).deleteRecipe(recipe.id);
                            Navigator.pop(ctx);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Recipe Deleted')),
                            );
                          },
                          child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(width: 10),
            ],
          ),

          // 2. RECIPE CONTENT
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // STATS
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildTag(Icons.timer, recipe.time),
                        const SizedBox(width: 10),
                        _buildTag(Icons.bar_chart, recipe.difficulty),
                        const SizedBox(width: 10),
                        _buildTag(Icons.local_fire_department, recipe.calories),
                        const SizedBox(width: 10),
                        _buildTag(Icons.fitness_center, recipe.protein),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // INGREDIENTS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Ingredients', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('${recipe.ingredients.length} items', style: TextStyle(color: Colors.grey[500])),
                    ],
                  ),
                  const SizedBox(height: 15),
                  ...recipe.ingredients.map((ingredient) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline, size: 20, color: Colors.green),
                            const SizedBox(width: 10),
                            Expanded(child: Text(ingredient, style: const TextStyle(fontSize: 16))),
                          ],
                        ),
                      )),

                  const Divider(height: 40, thickness: 1, color: Colors.grey),

                  // INSTRUCTIONS
                  if (recipe.instructions.isNotEmpty) ...[
                    const Text('Instructions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: recipe.instructions.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Text(
                                  recipe.instructions[index],
                                  style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 100), 
                ],
              ),
            ),
          ),
        ],
      ),

      // ADD TO GROCERY BUTTON
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 5,
            ),
            onPressed: () {
              for (var ingredient in recipe.ingredients) {
                ref.read(groceryListProvider.notifier).addItem(
                  ingredient, 
                  '1 pack', 
                  Priority.medium 
                );
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Added ${recipe.ingredients.length} items to Grocery List!'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.pop(context);
            },
            icon: const Icon(Icons.playlist_add, color: Colors.white),
            label: const Text(
              'Shop Ingredients',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  // --- UPDATED HELPER FOR ASSETS ---
  Widget _buildRecipeImage(String path) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => Container(color: Colors.grey[300]),
      );
    } else if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => Container(color: Colors.grey[300]),
      );
    } else {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => Container(color: Colors.grey[300]),
      );
    }
  }

  Widget _buildTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.black54),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }
}