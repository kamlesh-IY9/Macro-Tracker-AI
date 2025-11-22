import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/recipe_service.dart';
import 'recipe_builder_screen.dart';

class RecipesListScreen extends ConsumerWidget {
  const RecipesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipes = ref.watch(recipeServiceProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('My Recipes'),
      ),
      body: recipes.isEmpty
          ? const Center(
              child: Text(
                'No recipes yet. Create your first recipe!',
                style: TextStyle(color: Color(0xFF94A3B8)),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                final perServing = recipe.servings > 0 ? recipe.totalCalories / recipe.servings : recipe.totalCalories;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      recipe.name,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${perServing.toInt()} kcal per serving • ${recipe.servings} servings',
                      style: const TextStyle(color: Color(0xFF94A3B8)),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        ref.read(recipeServiceProvider.notifier).deleteRecipe(recipe.id);
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RecipeBuilderScreen()),
          );
        },
        backgroundColor: const Color(0xFF14B8A6),
        label: const Text('New Recipe'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
