import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:foodsync/features/grocery_list/providers/grocery_provider.dart';
import 'package:foodsync/features/grocery_list/models/grocery_item.dart';

void main() {
  // 1. Setup a "Fake" Database before tests run
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('GroceryNotifier Tests', () {
    
    test('Adding an item updates the list', () {
      // ARRANGE: Create the provider
      final notifier = GroceryNotifier();

      // ACT: Add an item
      notifier.addItem('Milk', '1 gallon', Priority.medium);

      // ASSERT: Check if it's there
      expect(notifier.state.length, 1);
      expect(notifier.state.first.name, 'Milk');
      expect(notifier.state.first.quantity, '1 gallon');
    });

    test('Deleting an item removes it from list', () {
      // ARRANGE
      final notifier = GroceryNotifier();
      notifier.addItem('Eggs', '12', Priority.high);
      final itemId = notifier.state.first.id; // Get the ID of the item we just added

      // ACT: Delete it
      notifier.deleteItem(itemId);

      // ASSERT: List should be empty
      expect(notifier.state.length, 0);
    });
  });
}