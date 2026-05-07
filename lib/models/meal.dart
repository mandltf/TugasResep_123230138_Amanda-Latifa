class Meal {
  final String id;
  final String name;
  final String? category;
  final String? area;
  final String? instructions;
  final String thumbnail;
  final List<Ingredient> ingredients;
  final String? tags;

  Meal({
    required this.id,
    required this.name,
    this.category,
    this.area,
    this.instructions,
    required this.thumbnail,
    required this.ingredients,
    this.tags,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    List<Ingredient> ingredients = [];
    
    // Parse ingredients (max 20)
    for (int i = 1; i <= 20; i++) {
      String? ingredient = json['strIngredient$i'];
      String? measure = json['strMeasure$i'];
      
      if (ingredient != null && ingredient.isNotEmpty && measure != null && measure.isNotEmpty) {
        ingredients.add(Ingredient(
          name: ingredient,
          measure: measure.trim(),
        ));
      }
    }
    
    return Meal(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? '',
      category: json['strCategory'],
      area: json['strArea'],
      instructions: json['strInstructions'],
      thumbnail: json['strMealThumb'] ?? '',
      ingredients: ingredients,
      tags: json['strTags'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'area': area,
      'instructions': instructions,
      'thumbnail': thumbnail,
      'tags': tags,
    };
  }

  // Untuk penyimpanan favorit (simplified)
  factory Meal.fromSimpleJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'],
      area: json['area'],
      instructions: json['instructions'],
      thumbnail: json['thumbnail'] ?? '',
      ingredients: [],
      tags: json['tags'],
    );
  }
}

class Ingredient {
  final String name;
  final String measure;

  Ingredient({required this.name, required this.measure});
}