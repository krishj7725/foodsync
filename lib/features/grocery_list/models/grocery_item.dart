enum Priority { low, medium, high }

class GroceryItem {
  final String id;
  final String name;
  final String quantity;
  final bool isCompleted;
  final Priority priority;

  GroceryItem({
    required this.id,
    required this.name,
    required this.quantity,
    this.isCompleted = false,
    this.priority = Priority.medium,
  });

  // 1. Convert Object to Text (JSON) - Used for Saving
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'isCompleted': isCompleted,
      'priority': priority.index, // Save the priority as a number (0, 1, 2)
    };
  }

  // 2. Convert Text (JSON) to Object - Used for Loading
  factory GroceryItem.fromJson(Map<String, dynamic> json) {
    return GroceryItem(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'],
      isCompleted: json['isCompleted'],
      priority: Priority.values[json['priority']], // Convert number back to Priority
    );
  }

  GroceryItem copyWith({
    String? id,
    String? name,
    String? quantity,
    bool? isCompleted,
    Priority? priority,
  }) {
    return GroceryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
    );
  }
}