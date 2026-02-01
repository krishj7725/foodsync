import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe.dart';

final recipeProvider = StateNotifierProvider<RecipeNotifier, List<Recipe>>((ref) {
  return RecipeNotifier();
});

class RecipeNotifier extends StateNotifier<List<Recipe>> {
  // Start with empty, then load
  RecipeNotifier() : super([]) {
    _loadData();
  }

  // --- PERSISTENCE ---
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? dataString = prefs.getString('saved_recipes');

    if (dataString != null) {
      // Load saved recipes
      final List<dynamic> jsonList = jsonDecode(dataString);
      state = jsonList.map((json) => Recipe.fromJson(json)).toList();
    } else {
      // If NO data exists (First time user), load the default starter recipes
      state = _getStarterRecipes();
      _saveData(); // Save them so they persist
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final String dataString = jsonEncode(state.map((item) => item.toJson()).toList());
    await prefs.setString('saved_recipes', dataString);
  }

  // --- ACTIONS ---

  void addRecipe(Recipe recipe) {
    state = [...state, recipe];
    _saveData(); // Save immediately
  }

  void deleteRecipe(String id) {
    state = state.where((recipe) => recipe.id != id).toList();
    _saveData(); // Save immediately
  }

  // --- DEFAULT DATA ---
  List<Recipe> _getStarterRecipes() {
    return [
      Recipe(
        id: '1',
        title: 'Avocado Toast',
        time: '10 min',
        difficulty: 'Easy',
        calories: '250 kcal',
        protein: '8g',
        imageUrl: 'https://images.unsplash.com/photo-1588137372308-15f75323ca8d?auto=format&fit=crop&w=500&q=60',
        ingredients: ['1 Slice Sourdough Bread', '1/2 Ripe Avocado', '1 Egg', 'Chilli Flakes', 'Salt & Pepper'],
        instructions: [
          'Toast the bread slice until golden brown and crispy.',
          'In a small bowl, mash the avocado with a fork. Season with salt and pepper.',
          'Fry the egg in a pan to your liking (sunny side up is recommended).',
          'Spread the mashed avocado generously over the toast.',
          'Top with the fried egg and sprinkle with chilli flakes.'
        ],
      ),
      Recipe(
        id: '2',
        title: 'Pasta Carbonara',
        time: '25 min',
        difficulty: 'Medium',
        calories: '600 kcal',
        protein: '20g',
        imageUrl: 'assets/images/pasta_carbonara.jpg',
        ingredients: ['200g Spaghetti', '2 Large Eggs', '100g Pancetta', '50g Parmesan', 'Black Pepper'],
        instructions: [
          'Boil a large pot of salted water and cook spaghetti until al dente.',
          'While pasta cooks, fry the pancetta in a pan until crispy. Remove from heat.',
          'In a bowl, whisk together the eggs and grated parmesan cheese with plenty of black pepper.',
          'Drain the pasta but keep 1/2 cup of pasta water.',
          'Toss the hot pasta into the pan with the pancetta. Remove pan from heat completely.',
          'Pour the egg mixture over the pasta and toss quickly so the eggs create a creamy sauce.',
        ],
      ),
    ];
  }
}