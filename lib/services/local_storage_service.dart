import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {

  /// Save user ID to local storage
  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

  /// Get user ID from local storage
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  /// Clear user ID from local storage
  static Future<void> clearUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
  }

  /// Save category completion flag for a specific user
  static Future<void> setCategoriesCompleted(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('categoriesCompleted_$userId', true);
  }

  /// Check if the user has completed category selection
  static Future<bool> hasCompletedCategories(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('categoriesCompleted_$userId') ?? false;
  }
  
  static Future<void> saveSelectedCategoriesDraft(String userId, List<String> categories) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('selectedCategories_$userId', categories);
  }

  static Future<List<String>?> getSelectedCategoriesDraft(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('selectedCategories_$userId');
  }

  static Future<void> deleteSelectedCategoriesDraft(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('selectedCategories_$userId');
  }

  /// Guarda flag temporal que indica que hay selección de categorías pendiente
static Future<void> setPendingCategoryNotice(bool value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('pendingCategoryNotice', value);
}

/// Obtiene el flag temporal para mostrar aviso de selección pendiente
static Future<bool> getPendingCategoryNotice() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('pendingCategoryNotice') ?? false;
}

/// Borra el flag para que no se muestre de nuevo
static Future<void> clearPendingCategoryNotice() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('pendingCategoryNotice');
}

}
