import 'package:shared_preferences/shared_preferences.dart';
import 'package:laugh_lab/constants/app_constants.dart';

class DraftUtils {
  // Save a draft joke
  static Future<void> saveDraftJoke(String content) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.draftJokeKey, content);
  }
  
  // Save a draft joke category
  static Future<void> saveDraftCategory(String category) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.draftJokeCategoryKey, category);
  }
  
  // Load a draft joke
  static Future<String> loadDraftJoke() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.draftJokeKey) ?? '';
  }
  
  // Load a draft joke category
  static Future<String> loadDraftCategory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.draftJokeCategoryKey) ?? 
        AppConstants.jokeCategories.first;
  }
  
  // Clear a draft joke
  static Future<void> clearDraftJoke() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.draftJokeKey);
    await prefs.remove(AppConstants.draftJokeCategoryKey);
  }
  
  // Check if a draft joke exists
  static Future<bool> hasDraftJoke() async {
    final prefs = await SharedPreferences.getInstance();
    final draft = prefs.getString(AppConstants.draftJokeKey);
    return draft != null && draft.isNotEmpty;
  }
} 