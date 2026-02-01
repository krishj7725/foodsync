import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart'; 
import '../models/recipe.dart';
import '../providers/recipe_provider.dart';

class AddRecipeScreen extends ConsumerStatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  ConsumerState<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends ConsumerState<AddRecipeScreen> {
  final _titleController = TextEditingController();
  final _timeController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();
  
  String _selectedDifficulty = 'Easy';
  File? _selectedImage; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add New Recipe', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Overview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 15),
            
            _buildSimpleTextField(_titleController, 'Recipe Title', 'e.g. Grandma\'s Apple Pie'),
            const SizedBox(height: 15),

            // --- IMAGE PICKER SECTION ---
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                  image: _selectedImage != null
                      ? DecorationImage(
                          image: FileImage(_selectedImage!), 
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _selectedImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined, size: 40, color: Colors.grey[400]),
                          const SizedBox(height: 10),
                          Text('Tap to add photo', style: TextStyle(color: Colors.grey[500])),
                        ],
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: _buildNumberField(_timeController, 'Cook Time', '45', 'mins'),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedDifficulty,
                    decoration: InputDecoration(
                      labelText: 'Difficulty',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    items: ['Easy', 'Medium', 'Hard'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedDifficulty = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            
            // --- NEW NUMBER ONLY FIELDS FOR CALORIES & PROTEIN ---
             Row(
              children: [
                Expanded(
                  child: _buildNumberField(_caloriesController, 'Calories', '350', 'kcal'),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildNumberField(_proteinController, 'Protein', '12', 'g'),
                ),
              ],
            ),

            const SizedBox(height: 30),

            const Text('Ingredients', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            TextField(
              controller: _ingredientsController,
              maxLines: 5,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: '2 Eggs\n1 Cup Flour\n200ml Milk\nSalt',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),

            const SizedBox(height: 30),

            const Text('Instructions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            TextField(
              controller: _instructionsController,
              maxLines: 8,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: '1. Preheat the oven...\n2. Mix dry ingredients...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                ),
                onPressed: _saveRecipe,
                child: const Text('Save to Cookbook', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Helper for regular text (Title)
  Widget _buildSimpleTextField(TextEditingController controller, String label, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  // NEW Helper for Number Inputs (Time, Calories, Protein)
  Widget _buildNumberField(TextEditingController controller, String label, String hint, String suffix) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number, // <--- NUMBERS ONLY
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffix, // <--- SHOWS 'g' or 'kcal' automatically
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  void _saveRecipe() {
    if (_titleController.text.isEmpty) return;

    List<String> parseList(String text) {
      return text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }

    String finalImagePath = _selectedImage != null 
        ? _selectedImage!.path 
        : 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=500&q=60';

    // --- AUTO-FORMAT LOGIC ---
    
    // Time: Add " min" if missing
    String finalTime = _timeController.text;
    if (finalTime.isNotEmpty && !finalTime.toLowerCase().contains('min')) {
      finalTime = '$finalTime min';
    }

    // Calories: Add " kcal" if missing
    String finalCals = _caloriesController.text;
    if (finalCals.isNotEmpty && !finalCals.toLowerCase().contains('kcal')) {
      finalCals = '$finalCals kcal';
    }

    // Protein: Add "g" if missing
    String finalProtein = _proteinController.text;
    if (finalProtein.isNotEmpty && !finalProtein.toLowerCase().contains('g')) {
      finalProtein = '${finalProtein}g';
    }

    final newRecipe = Recipe(
      id: DateTime.now().toString(),
      title: _titleController.text,
      time: finalTime.isEmpty ? 'N/A' : finalTime,
      difficulty: _selectedDifficulty,
      calories: finalCals.isEmpty ? 'N/A' : finalCals, // Use formatted value
      protein: finalProtein.isEmpty ? 'N/A' : finalProtein, // Use formatted value
      ingredients: parseList(_ingredientsController.text),
      instructions: parseList(_instructionsController.text),
      imageUrl: finalImagePath,
    );

    ref.read(recipeProvider.notifier).addRecipe(newRecipe);
    Navigator.pop(context);
  }
}