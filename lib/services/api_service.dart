import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal.dart';

class ApiService {
  static const String baseUrl = 'https://www.themealdb.com/api/json/v1/1';
  
  static Future<List<Meal>> searchMeals(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search.php?s=$query'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null) {
          List<Meal> meals = [];
          for (var mealJson in data['meals']) {
            meals.add(Meal.fromJson(mealJson));
          }
          return meals;
        }
      }
      return [];
    } catch (e) {
      print('Error mencari meals: $e');
      return [];
    }
  }
  
  static Future<Meal?> getMealById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/lookup.php?i=$id'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null && data['meals'].isNotEmpty) {
          return Meal.fromJson(data['meals'][0]);
        }
      }
      return null;
    } catch (e) {
      print('Error mendapatkan detail meal: $e');
      return null;
    }
  }
  
  static Future<List<Meal>> getRandomMeals({int count = 10}) async {
    List<Meal> meals = [];
    for (int i = 0; i < count; i++) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/random.php'),
        );
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['meals'] != null && data['meals'].isNotEmpty) {
            meals.add(Meal.fromJson(data['meals'][0]));
          }
        }
        await Future.delayed(const Duration(milliseconds: 100));
      } catch (e) {
        print('Error mendapatkan meal acak: $e');
      }
    }
    return meals;
  }
  
  static Future<List<Meal>> getMealsByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/filter.php?c=$category'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null) {
          List<Meal> meals = [];
          for (var mealJson in data['meals']) {
            Meal? fullMeal = await getMealById(mealJson['idMeal']);
            if (fullMeal != null) {
              meals.add(fullMeal);
            }
          }
          return meals;
        }
      }
      return [];
    } catch (e) {
      print('Error mendapatkan meals berdasarkan kategori: $e');
      return [];
    }
  }
}