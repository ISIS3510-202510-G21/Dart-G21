import 'package:dart_g21/data/database/app_database.dart';
import 'package:dart_g21/models/category.dart';
import 'package:dart_g21/repositories/category_repository.dart';
import 'package:dart_g21/repositories/drift_repository.dart';
import 'package:dart_g21/repositories/localStorage_repository.dart';

class CategoryController {
  final CategoryRepository _categoryRepository = CategoryRepository();
  final LocalStorageRepository _localStorageRepository = LocalStorageRepository();
  final DriftRepository _driftRepository = DriftRepository(AppDatabase());


  Stream<List<Category_event>> getCategoriesStream() {
    return _categoryRepository.getCategoriesStream();
  }

  Future<Category_event?> getCategoryById(String categoryId) async {
    return await _categoryRepository.getCategoryById(categoryId);
  }

  Future<void> addCategory(Category_event category) async {
    await _categoryRepository.addCategory(category);
  }

  Future<void> updateCategory(Category_event category) async {
    await _categoryRepository.updateCategory(category);
  }

  Future<void> deleteCategory(String categoryId) async {
    await _categoryRepository.deleteCategory(categoryId);
  }

  Stream<List<Category_event>> getCategoriesStreamOffline() async* {
    List<Category_event> categories = _localStorageRepository.getCategories();
    yield categories;
  }

  Future<Category_event?> getCategoryByIdOffline(String categoryId) async {
    return await _localStorageRepository.getCategoryById(categoryId);
  }

  Future<List<Category_event>> getCachedCategories() async {
    return _localStorageRepository.getCategories();
  }

  Future<void> saveCategoriesToCache(List<Category_event> categories) async {
    await _localStorageRepository.saveCategories(categories);
  }

  Future<List<Category_event>> getCachedCategoriesDrift() async {
    return _driftRepository.getCategoriesDrift();
  }
  Future<void> saveCategoriesToCacheDrift(List<Category_event> categories) async {
    await _driftRepository.saveCategoriesDrift(categories);
  }
  Future<void> saveCategoryToDrift(Category_event category) async {
    await _driftRepository.saveCategoryDrift(category);
  }
  Future<Category_event?> getCategoryByIdOfflineDrift(String id) async {
    return await _driftRepository.getCategoryByIdDrift(id);
  }

  Stream<List<Category_event>> getCategoriesStreamOfflineDrift() async* {
    List<Category_event> categories = await _driftRepository.getCategoriesDrift();
    yield categories;
  }


}
