import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/grocery_item.dart';
import '../providers/grocery_provider.dart';
import '../../party/screens/party_screen.dart'; 

class GroceryScreen extends ConsumerWidget {
  const GroceryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groceryList = ref.watch(groceryListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Grocery List', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PartyScreen()));
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.group, color: Colors.blue[700], size: 20),
            ),
          ),
          const SizedBox(width: 15),
        ],
      ),
      // --- NEW EMPTY STATE ---
      body: groceryList.isEmpty
          ? Center(
              child: Opacity(
                opacity: 0.6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart_checkout_rounded, size: 90, color: Colors.grey[300]),
                    const SizedBox(height: 20),
                    const Text(
                      'Your fridge is empty!',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Tap the + button to add items\nor find a recipe to cook.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: groceryList.length,
              itemBuilder: (context, index) {
                final item = groceryList[index];

                // --- NEW UNDO LOGIC ---
                return Dismissible(
                  key: Key(item.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.delete, color: Colors.red),
                  ),
                  onDismissed: (_) {
                    // 1. Capture Item Data
                    final deletedItem = item;
                    
                    // 2. Delete it
                    ref.read(groceryListProvider.notifier).deleteItem(item.id);

                    // 3. Show Undo Snackbar
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${item.name} removed'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        action: SnackBarAction(
                          label: 'UNDO',
                          textColor: Colors.yellow,
                          onPressed: () {
                            // 4. Restore Item
                            ref.read(groceryListProvider.notifier).addItem(
                              deletedItem.name,
                              deletedItem.quantity,
                              deletedItem.priority
                            );
                          },
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: item.isCompleted ? Colors.grey[50] : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: item.isCompleted ? Colors.transparent : Colors.grey[100]!,
                      ),
                      boxShadow: item.isCompleted
                          ? []
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                    ),
                    child: Row(
                      children: [
                        Transform.scale(
                          scale: 1.2,
                          child: Checkbox(
                            value: item.isCompleted,
                            activeColor: Colors.grey,
                            shape: const CircleBorder(),
                            onChanged: (val) {
                              ref.read(groceryListProvider.notifier).toggleStatus(item.id);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                                  color: item.isCompleted ? Colors.grey : Colors.black,
                                ),
                              ),
                              if (item.quantity.isNotEmpty)
                                Text(
                                  item.quantity,
                                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                                ),
                            ],
                          ),
                        ),
                        if (!item.isCompleted) _buildPriorityTag(item.priority),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildPriorityTag(Priority priority) {
    Color color;
    String text;
    
    switch (priority) {
      case Priority.high:
        color = Colors.red;
        text = 'Urgent';
        break;
      case Priority.medium:
        return const SizedBox();
      case Priority.low:
        color = Colors.blue;
        text = 'Later';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
  
  static void showAddDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final qtyController = TextEditingController();
    Priority selectedPriority = Priority.medium;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Text('Add Item', style: TextStyle(fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Product', hintText: 'e.g. Milk'),
                  autofocus: true,
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: qtyController,
                  decoration: const InputDecoration(labelText: 'Quantity', hintText: 'e.g. 2 cartons'),
                ),
                const SizedBox(height: 20),
                const Text('Urgency', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _priorityOption(Priority.high, selectedPriority, 'Urgent', Colors.red, () {
                      setState(() => selectedPriority = Priority.high);
                    }),
                    const SizedBox(width: 10),
                    _priorityOption(Priority.medium, selectedPriority, 'Normal', Colors.black, () {
                      setState(() => selectedPriority = Priority.medium);
                    }),
                    const SizedBox(width: 10),
                    _priorityOption(Priority.low, selectedPriority, 'Later', Colors.blue, () {
                      setState(() => selectedPriority = Priority.low);
                    }),
                  ],
                )
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    ref.read(groceryListProvider.notifier).addItem(
                          nameController.text,
                          qtyController.text,
                          selectedPriority,
                        );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        }
      ),
    );
  }

  static Widget _priorityOption(Priority value, Priority groupValue, String label, Color color, VoidCallback onTap) {
    final isSelected = value == groupValue;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? color : Colors.grey[300]!),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}