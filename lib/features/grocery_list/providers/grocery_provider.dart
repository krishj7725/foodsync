import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/grocery_item.dart';

final groceryListProvider = StateNotifierProvider<GroceryNotifier, List<GroceryItem>>((ref) {
  return GroceryNotifier();
});

class GroceryNotifier extends StateNotifier<List<GroceryItem>> {
  GroceryNotifier() : super([]) {
    _loadData();
  }

  // --- PERSISTENCE (Loading & Saving) ---
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? dataString = prefs.getString('grocery_list');
    
    if (dataString != null) {
      final List<dynamic> jsonList = jsonDecode(dataString);
      state = jsonList.map((json) => GroceryItem.fromJson(json)).toList();
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final String dataString = jsonEncode(state.map((item) => item.toJson()).toList());
    await prefs.setString('grocery_list', dataString);
  }

  // --- SMART ACTIONS ---

  // 1. SMART ADD (Handles Duplicates)
  void addItem(String name, String quantity, Priority priority) {
    // Check if item exists (Case insensitive)
    final existingIndex = state.indexWhere(
      (item) => item.name.toLowerCase().trim() == name.toLowerCase().trim()
    );

    if (existingIndex >= 0) {
      // CASE A: Item exists! Update it.
      final existingItem = state[existingIndex];
      
      // Merge quantities cleanly (e.g., "1 pack" + "2 packs" -> "1 pack, 2 packs")
      String newQuantity = existingItem.quantity;
      if (quantity.isNotEmpty) {
        newQuantity = existingItem.quantity.isEmpty 
            ? quantity 
            : '${existingItem.quantity}, $quantity';
      }

      final updatedItem = existingItem.copyWith(
        quantity: newQuantity,
        priority: priority, // Update urgency to the new one
        isCompleted: false, // Uncheck it if we are buying more
      );

      // Replace the item in the list
      state = [
        ...state.sublist(0, existingIndex),
        updatedItem,
        ...state.sublist(existingIndex + 1),
      ];
    } else {
      // CASE B: New Item
      final newItem = GroceryItem(
        id: DateTime.now().toString(),
        name: name,
        quantity: quantity,
        priority: priority,
      );
      state = [...state, newItem];
    }

    _sortList();
    _saveData();
  }

  // 2. DELETE
  void deleteItem(String id) {
    state = state.where((item) => item.id != id).toList();
    _saveData();
  }

  // 3. TOGGLE
  void toggleStatus(String id) {
    state = state.map((item) {
      if (item.id == id) {
        return item.copyWith(isCompleted: !item.isCompleted);
      }
      return item;
    }).toList();
    _sortList();
    _saveData();
  }

  // 4. SORTING LOGIC
  void _sortList() {
    state.sort((a, b) {
      // Completed items go to bottom
      if (a.isCompleted && !b.isCompleted) return 1;
      if (!a.isCompleted && b.isCompleted) return -1;
      
      // If active, High Priority goes to top
      if (!a.isCompleted && !b.isCompleted) {
        return b.priority.index.compareTo(a.priority.index);
      }
      return 0;
    });
    // Force UI refresh
    state = [...state];
  }
}