class Recipe {
  final String id;
  final String title;
  final String time;
  final String difficulty;
  final String calories;
  final String protein;
  final String imageUrl;
  final List<String> ingredients;
  final List<String> instructions;

  Recipe({
    required this.id,
    required this.title,
    required this.time,
    required this.difficulty,
    this.calories = 'N/A',
    this.protein = 'N/A',
    required this.imageUrl,
    required this.ingredients,
    required this.instructions,
  });

  // 1. Convert Object to Text (JSON) - For Saving
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'time': time,
      'difficulty': difficulty,
      'calories': calories,
      'protein': protein,
      'imageUrl': imageUrl,
      'ingredients': ingredients,
      'instructions': instructions,
    };
  }

  // 2. Convert Text (JSON) to Object - For Loading
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      title: json['title'],
      time: json['time'],
      difficulty: json['difficulty'],
      calories: json['calories'] ?? 'N/A',
      protein: json['protein'] ?? 'N/A',
      imageUrl: json['imageUrl'],
      ingredients: List<String>.from(json['ingredients']),
      instructions: List<String>.from(json['instructions']),
    );
  }
}